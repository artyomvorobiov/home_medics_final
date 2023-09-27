import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nope/providers/address.dart';
import 'package:nope/providers/profiles.dart';

import '../screens/all_drugs_screen.dart';
import '../screens/drug_detail_screen.dart';
import '../providers/drugs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/drug.dart';
import '../screens/splash_screen.dart';

class EventsGrid extends StatefulWidget {
  int pageWeComeFrom;
  bool haveFinalData = false;
  int minPrice;
  int maxPrice;
  String selectedDate;
  Map<String, dynamic> selectedCategories;
  Address address;
  EventsGrid(this.selectedCategories, this.pageWeComeFrom,
      {this.minPrice = null,
      this.maxPrice = null,
      this.selectedDate,
      this.address = null});

  @override
  State<EventsGrid> createState() => _EventsGridState();
}

class _EventsGridState extends State<EventsGrid> {
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  bool haveFinalData = false;
  List<Drug> drugs;
  String lastFamilyId;
  List<Drug> newDrugs;
  List<Drug> visible;
  String selectedAddress;
  List<Drug> _searchResults = [];
  bool T = false;
  DatabaseReference _drugsRef = FirebaseDatabase.instance.ref().child('drugs');
  FirebaseStorage storage = FirebaseStorage.instance;
  bool hasExpiredDrugs = false;
  String searchText;

  void findCorrectEvents() async {
    print('CAll find correct');
    await Provider.of<Drugs>(context, listen: false).fetchAndSetEvents(false);
    drugs = await Provider.of<Drugs>(context, listen: false).visibleEvents;
    final currentDate = DateTime.now();
    for (final drug in drugs) {
      print('drug.dateTime');
      print(drug.dateTime);
      final expirationDate = DateTime.parse(drug.dateTime);
      final daysTillExpiration =
          int.parse(drug.dayTillExp); // Парсим день до истечения срока годности
      final expirationWithDays =
          currentDate.add(Duration(days: daysTillExpiration));
      if (expirationWithDays.isAfter(expirationDate)) {
        hasExpiredDrugs = true;
        break; // Есть лекарства с истекшим сроком, больше проверять не нужно
      }
    }
    for (String key in widget.selectedCategories.keys) {
      if (widget.selectedCategories[key] == true) {
        drugs.removeWhere((element) => !isAppropriate(element));
        break;
      }
    }
  }

  bool isDateCorrect(Drug drug, DateTime selectedDate) {
    return true;
  }

  bool isPriceCorrect(Drug drug) {
    print('curEventPrice ${drug.price} minPrice${widget.minPrice}');
    print('curEventPrice ${drug.price} maxPrice${widget.maxPrice}');
    if (int.parse(drug.price) < widget.minPrice ||
        int.parse(drug.price) > widget.maxPrice) {
      return false;
    }
    return true;
  }

  int levenshteinDistance(String a, String b) {
    int m = a.length;
    int n = b.length;
    if (m == 0) return n;
    if (n == 0) return m;
    List<List<int>> dp = List.generate(m + 1, (index) => List<int>(n + 1));
    for (int i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= n; j++) {
      dp[0][j] = j;
    }
    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        int cost = a[i - 1] == b[j - 1] ? 0 : 1;
        dp[i][j] = min(
          dp[i - 1][j] + 1,
          min(
            dp[i][j - 1] + 1,
            dp[i - 1][j - 1] + cost,
          ),
        );
      }
    }
    return dp[m][n];
  }

  void findFavorite() async {
    await Provider.of<Drugs>(context, listen: false).fetchAndSetEvents();
    drugs = await Provider.of<Drugs>(context, listen: false).favoriteEvents;
    drugs.removeWhere((element) => !isAppropriate(element));
  }

  void findMyEvents() async {
    await Provider.of<Drugs>(context, listen: false).fetchAndSetEvents(true);
    drugs = await Provider.of<Drugs>(context, listen: false).drugs;
    drugs.removeWhere((element) => !isAppropriate(element));
  }

  bool isAppropriate(Drug drug) {
    if (Profiles.curProfile.familyId == drug.familyID) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    await Provider.of<Drugs>(context, listen: false).fetchAndSetEvents(false);
    await Provider.of<Profiles>(context, listen: false).checkIfAdded();
    setState(() {
      widget.haveFinalData = false;
      isLoading = true;
    });
    if (widget.pageWeComeFrom == 1) {
      await findCorrectEvents();
    } else if (widget.pageWeComeFrom == 2) {
      await findMyEvents();
    } else if (widget.pageWeComeFrom == 3) {
      await findFavorite();
    }
    setState(() {
      widget.haveFinalData = true;
      isLoading = false;
    });
  }

  void _onSearchTextChanged(searchText) async {
    drugs = null;
    var t = _drugsRef.ref.path;
    await Provider.of<Drugs>(context, listen: false).fetchAndSetEvents();
    newDrugs = await Provider.of<Drugs>(context, listen: false).favoriteEvents;
    if (searchText.trim().isEmpty) {
      fetchData();
    } else {
      DatabaseEvent snapshot = (await _drugsRef.once());
      var y = snapshot.snapshot.value;
      print("$y    aaaaaaa");
      if (snapshot.snapshot.value != null) {
        print("HELLLOOOOOOOOOO $t");
        Map<dynamic, dynamic> map = snapshot.snapshot.value;
        List<Drug> searchResults = [];
        map.forEach((key, value) {
          Drug drug = Drug(
            id: key,
            name: value['name'],
            price: value['price'],
            address: Address(id: '1', title: value['address']['title']),
            dateTime: value['dateTime'],
            dayTillExp: value['dayTillExp'],
            extraInformation: value['extraInformation'],
            familyID: value['familyID'],
            show: value['show'],
            creatorId: value['creatorId'],
            description: value['description'],
            profileId: value['profileId'],
          );
          if (((widget.pageWeComeFrom == 3 && newDrugs.contains(drug)) ||
                  (widget.pageWeComeFrom == 2 &&
                      Profiles.curProfile.address.title ==
                          drug.address.title) ||
                  (widget.pageWeComeFrom == 1 &&
                      drug.familyID == Profiles.curProfile.familyId &&
                      (drug.show == true ||
                          drug.profileId == Profiles.curProfileId))) &&
              ((levenshteinDistance(
                          drug.name.toLowerCase(), searchText.toLowerCase()) <=
                      2) ||
                  (levenshteinDistance(drug.extraInformation.toLowerCase(),
                          searchText.toLowerCase()) <=
                      2) ||
                  (drug.extraInformation
                      .toLowerCase()
                      .startsWith(searchText.toLowerCase())) ||
                  (drug.name
                      .toLowerCase()
                      .startsWith(searchText.toLowerCase())))) {
            searchResults.add(drug);
          }
        });
        setState(() {
          drugs = searchResults;
          print("searchResults");
          print(searchResults);
        });
      } else {
        setState(() {
          drugs = [];
        });
      }
    }
  }

  void openDetailScreen(String id) async {
    await Navigator.of(context).pushNamed(
      EventDetailScreen.routeName,
      arguments: id,
    );
    setState(() {
      widget.haveFinalData = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.haveFinalData) {
      fetchData();
    }
    bool isDrugExpired(Drug drug) {
      final currentDate = DateTime.now();
      final expirationDate = DateTime.parse(drug.dateTime);
      final daysTillExpiration =
          int.parse(drug.dayTillExp); // Парсим день до истечения срока годности
      final expirationWithDays =
          currentDate.add(Duration(days: daysTillExpiration));

      return expirationWithDays.isAfter(expirationDate);
    }

    Future<void> _showExpiredDrugsDialog(BuildContext context) async {
      // Здесь вы можете создать и настроить диалог для отображения лекарств с истекшим сроком
      // Пример:
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Лекарства с истекшим сроком годности'),
          content: Container(
            width: 170,
            height: 200,
            child: ListView.builder(
              itemCount: drugs.length,
              itemBuilder: (ctx, index) {
                final drug = drugs[index];
                if (isDrugExpired(drug)) {
                  return ListTile(
                    title: Text(drug.name),
                    subtitle: Text('Срок годности: ${drug.dateTime}'),
                  );
                } else {
                  return SizedBox
                      .shrink(); // Скрыть элементы, которые не истекли
                }
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Закрыть',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }

    void _showAddressSelectionDialog(BuildContext context) async {
      final List<String> availableAddresses =
          await Provider.of<Drugs>(context, listen: false)
              .getAvailableAddresses(Profiles.curProfile.familyId);
      if (availableAddresses.isEmpty) {
        return;
      }
      if (selectedAddress == null) {
        T = false;
        selectedAddress = availableAddresses[0];
      } // Выберите адрес по умолчанию или другую логику

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          // backgroundColor: Theme.of(context).colorScheme.secondary,
          scrollable: true,
          title: Text('Выберите адрес'),
          content: SingleChildScrollView(
            child: Container(
              // color: Theme.of(context).colorScheme.secondary,
              width: 170,
              height: 200,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Отображение списка доступных адресов
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: availableAddresses.length,
                      itemBuilder: (ctx, index) {
                        final address = availableAddresses[index];
                        return ListTile(
                          title: Text(address),
                          onTap: () {
                            // Пользователь выбрал адрес
                            selectedAddress = address;
                            T = true;
                            print('selectedAddress $selectedAddress');
                            Provider.of<Drugs>(context, listen: false)
                                .setSelectedAddress(selectedAddress);
                            Navigator.of(context).pop();
                            fetchData();
                            // Navigator.of(context).pop();
                          },
                          tileColor: (T && address == selectedAddress)
                              ? Theme.of(context).primaryColor // Цвет выделения
                              : null,
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Отмена',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Сбросить фильтры',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                T = false;
                selectedAddress = null;
                Provider.of<Drugs>(context, listen: false)
                    .setSelectedAddress(selectedAddress);
                Navigator.of(context).pop();
                fetchData();
              },
            ),
          ],
        ),
      );
    }

    if (drugs == null || drugs.length == 0) {
      if (T) {
        return Container(
          color: Theme.of(context).colorScheme.secondary,
          child: Column(
            children: [
              Container(
                width: 300,
                height: 70,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                margin: EdgeInsets.only(top: 10.0),
                child: Align(
                  alignment: Alignment
                      .center, // Выравнивание по центру как по горизонтали, так и по вертикали
                  child: InkWell(
                    onTap: () => _showAddressSelectionDialog(
                        context), // Переход на страницу личных данных
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .start, // Выравнивание по центру по горизонтали
                      children: [
                        Icon(
                          Icons.location_on, // Иконка "Личные данные"
                          size: 30.0,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        SizedBox(width: 5),
                        Text(
                          "Выберите адрес",
                          style: TextStyle(
                            fontSize: 22,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  color: Theme.of(context).colorScheme.secondary,
                  child: Center(
                    child: Text("У вас нет лекарств",
                        style: TextStyle(
                          fontSize: 22,
                          color: Theme.of(context).primaryColor,
                        )),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 30),
                child: Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/palm-tree.png',
                    fit: BoxFit.fill,
                    height: 220,
                    width: 220,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 30),
                child: Container(
                  color: Theme.of(context).colorScheme.secondary,
                  child: Center(
                    child: Text(
                        "Добавьте лекарства, нажав на плюс справа снизу. Не забудьте перед этим ввести или сгенерировать код семьи в личных данных!",
                        style: TextStyle(
                          fontSize: 22,
                          color: Theme.of(context).primaryColor,
                        )),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return Container(
          color: Theme.of(context).colorScheme.secondary,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchTextChanged,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                  decoration: InputDecoration(
                    hintText: 'Поиск по названиям и комментариям',
                    hintStyle: TextStyle(
                      color: Theme.of(context)
                          .primaryColor, // Установка цвета подсказки
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Container(
                  color: Theme.of(context).colorScheme.secondary,
                  child: Center(
                    child: Text("У вас нет лекарств",
                        style: TextStyle(
                          fontSize: 22,
                          color: Theme.of(context).primaryColor,
                        )),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 30),
                child: Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/palm-tree.png',
                    fit: BoxFit.fill,
                    height: 220,
                    width: 220,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 30),
                child: Container(
                  color: Theme.of(context).colorScheme.secondary,
                  child: Center(
                    child: Text(
                        "Добавьте лекарства, нажав на плюс справа снизу. Не забудьте перед этим ввести или сгенерировать код семьи в личных данных!",
                        style: TextStyle(
                          fontSize: 22,
                          color: Theme.of(context).primaryColor,
                        )),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }

    Widget makeEventItem({
      final String id,
      final String title,
      final String comment,
      // final String address,
      //  final String imageUrl,
      final String price,
      final String address,
      final String time,
      final String descr,
      final bool isExpired,
    }) {
      Color cardColor = Theme.of(context).primaryColor;
      if (DateTime.now().isAfter(DateTime.parse(time))) {
        cardColor = Color.fromARGB(255, 202, 66, 57);
      } else if (isExpired) {
        cardColor = Color.fromARGB(
            255, 241, 138, 69); // Change color to red for expired drugs
      } // Change color to orange for drugs with current date >= expiration date

      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          child: GestureDetector(
            onTap: () => openDetailScreen(id),
            child: Container(
              decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              width: 100,
              height: MediaQuery.of(context).size.height * 0.15,
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: Hero(
                          tag: id,
                          child: Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.005,
                          ),
                        ),
                      ),
                      Positioned(
                        // bottom: 30,
                        //left: 50,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          width: 380,
                          height: MediaQuery.of(context).size.height * 0.07,
                          // color: Colors.black54,
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 30,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            textAlign: TextAlign.center,
                            softWrap: true,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SingleChildScrollView(
                    // Wrap the contents in a SingleChildScrollView
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align items to the start (left) of the column
                        children: [
                          // Address
                          Padding(
                            padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.height * 0.015,
                              // top: MediaQuery.of(context).size.height * 0.002,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.streetview,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                SizedBox(width: 5),
                                Container(
                                  width: 300,
                                  height: MediaQuery.of(context).size.height *
                                      0.025,
                                  child: Text(
                                    address.toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Description
                          Padding(
                            padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.height * 0.015,
                              top: MediaQuery.of(context).size.height * 0.002,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  price.toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  width: 300,
                                  height: MediaQuery.of(context).size.height *
                                      0.025,
                                  child: Text(
                                    descr.toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Comment
                          Padding(
                            padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.height * 0.015,
                              top: MediaQuery.of(context).size.height * 0.002,
                            ),
                            child: Row(
                              children: [
                                (comment != '' && comment != null)
                                    ? Icon(
                                        Icons.comment,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      )
                                    : SizedBox(width: 5),
                                SizedBox(width: 5),
                                Container(
                                  width: 300,
                                  height: MediaQuery.of(context).size.height *
                                      0.025,
                                  child: Text(
                                    comment,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Price
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchTextChanged,
              style: TextStyle(color: Theme.of(context).primaryColor),
              decoration: InputDecoration(
                hintText: 'Поиск по названиям и комментариям',
                hintStyle: TextStyle(
                  color: Theme.of(context)
                      .primaryColor, // Установка цвета подсказки
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          Container(
            width: 300,
            height: 70,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            margin: EdgeInsets.only(top: 10.0),
            child: Align(
              alignment: Alignment
                  .center, // Выравнивание по центру как по горизонтали, так и по вертикали
              child: InkWell(
                onTap: () => _showAddressSelectionDialog(
                    context), // Переход на страницу личных данных
                child: Row(
                  mainAxisAlignment: MainAxisAlignment
                      .start, // Выравнивание по центру по горизонтали
                  children: [
                    Icon(
                      Icons.location_on, // Иконка "Личные данные"
                      size: 30.0,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    SizedBox(width: 5),
                    Text(
                      "Выберите адрес",
                      style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: _searchResults.length > 0
                  ? _searchResults.length
                  : drugs.length,
              itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                value: _searchResults.length > 0 ? _searchResults[i] : drugs[i],
                child: makeEventItem(
                  id: _searchResults.length > 0
                      ? _searchResults[i].id
                      : drugs[i].id,
                  title: _searchResults.length > 0
                      ? _searchResults[i].name
                      : drugs[i].name,
                  price: _searchResults.length > 0
                      ? _searchResults[i].price
                      : drugs[i].price,
                  time: _searchResults.length > 0
                      ? _searchResults[i].dateTime
                      : drugs[i].dateTime,
                  comment: _searchResults.length > 0
                      ? _searchResults[i].extraInformation
                      : drugs[i].extraInformation,
                  descr: _searchResults.length > 0
                      ? _searchResults[i].description
                      : drugs[i].description,
                  address: _searchResults.length > 0
                      ? _searchResults[i].address.title
                      : drugs[i].address.title,
                  isExpired: isDrugExpired(
                      _searchResults.length > 0 ? _searchResults[i] : drugs[i]),
                ),
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 5 / 2,
                crossAxisSpacing: 2,
                mainAxisSpacing: 10,
              ),
            ),
          ),
          if (hasExpiredDrugs)
            Container(
              width: 200,
              height: 50,
              decoration: BoxDecoration(
                // color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                // border: Border.all(
                //   color: Theme.of(context).primaryColor,
                // ),
              ),
              margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Align(
                alignment: Alignment
                    .center, // Выравнивание по центру как по горизонтали, так и по вертикали
                child: InkWell(
                  onTap: () =>
                      _showExpiredDrugsDialog(context), // Переход на страницу
                  child: Icon(
                    Icons.warning, // Иконка "Личные данные"
                    size: 50.0,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
