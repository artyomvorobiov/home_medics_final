import 'package:firebase_auth/firebase_auth.dart';
import 'package:nope/providers/profile.dart';
import 'package:nope/screens/settings_screen.dart';

import '../providers/drug.dart';
import '../providers/drugs.dart';
import '/screens/search_places_screen.dart';
import 'package:provider/provider.dart';
import '../providers/profiles.dart';
import '/screens/profile_screen.dart';

import 'package:flutter/material.dart';

import '../providers/screen_number.dart';
import '../widgets/drugs_grid.dart';
import '../widgets/money_fields.dart';
import '../widgets/date_popup.dart';
import '../providers/address.dart';
import 'package:nope/screens/drugs_screen.dart';

import 'all_drugs_screen.dart';
import 'creating_drug_screen.dart';
import 'family_screen.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/main';
  static Address address;
  _MainScreenState state = _MainScreenState();

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool firstScreen = false;
  int selectedPageIndex = 0;
  bool fromDetail = false;
  String selecDate = null;
  Map<String, dynamic> categoriesForEventsScreen = {
    'Спорт': false,
    'Развлечения': false,
    'Вечеринки': false,
    'Прогулка': false,
    'Искусство': false,
    'Обучение': false,
    'Концерт': false,
    'Настольные игры': false,
    'Гастрономия': false,
  };

  List<Map<String, Object>> _pages;

  bool alreadyCreated = false;

  @override
  void initState() {
    setProfile();
    _pages = [
      {
        'page': AllDrugs(),
        'title': 'Лекарства',
      },
      {
        'page': ProfileScreen(),
        'title': 'Профиль',
      },
      {
        'page': FamilyMembersScreen(),
        'title': 'Моя семья',
      },
      {
        'page': SettingsScreen(),
        'title': 'Настройки',
      },
    ];
    super.initState();
  }

  void _selectPage(int index) {
    // print(index);

    setState(() {
      setProfile();
      ScreenNumber.number_of_screen = index;
    });
  }

  void displayFirstScreen() {
    setState(() {
      ScreenNumber.number_of_screen = 0;
      firstScreen = true;
    });
  }

  void checkEmail() {
    print("UUUUUUUUUUUUU");
    print(FirebaseAuth.instance.currentUser);
  }

  void createFunc() async {
    setProfile();
    if (Profiles.curProfile != null && Profiles.curProfile.familyId != '') {
      await Navigator.of(context).pushNamed(
        CreatingEventScreen.routeName,
        arguments: Drug(
          id: null,
          dateTime: null,
          description: '',
          price: '',
          name: '',
          address: Address(),
          extraInformation: '',
          creatorId: '',
          // categories: {
          //   'Спорт': false,
          //   'Развлечения': false,
          //   'Вечеринки': false,
          //   'Прогулка': false,
          //   'Искусство': false,
          //   'Обучение': false,
          //   'Концерт': false,
          //   'Настольные игры': false,
          //   'Гастрономия': false,
          // },
        ),
      );
      setState(() {
        Provider.of<Drugs>(context, listen: false).fetchAndSetEvents(false);
      });
    } else {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
              'Введите или сгенерируйте код семьи в личных данных, чтобы добавлять лекарства в аптечку'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  Future<void> addProfile() async {
    try {
      print('SET PROFILE');
      await Provider.of<Profiles>(context, listen: false).checkIfAdded();
    } catch (error) {
      throw error;
    }
  }

  void setProfile() async {
    print("AAAAAAAAAAAAA");
    Provider.of<Drugs>(context, listen: false).fetchAndSetEvents();
    await addProfile();
  }

  int newMinPrice = 0;
  int newMaxPrice = 1000000;

  @override
  Widget build(BuildContext context) {
    if (!firstScreen) {
      displayFirstScreen();
      // setProfile();
    }
    print("INDEX ${ScreenNumber.number_of_screen}");

    // for (var category in categoriesForEventsScreen.keys) {
    //   print('MAIN CATEGORY $category ${categoriesForEventsScreen[category]}');
    // }
    Provider.of<ScreenNumber>(context);
    // print("BUILDIK ${ScreenNumber.number_of_screen}");
    // print("DISPLAY12 ADDRESS ${address.title}");
    // if (!alreadyCreated) {
    setProfile();

    // checkEmail();
    //alreadyCreated = true;
    // }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Row(
          children: [
            Container(
              height: 19,
              child: Text(
                'Домашняя аптечка',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              height: 20,
            ),
          ],
        ),
      ),
      body: (_pages[ScreenNumber.number_of_screen % 4]['title'] == 'Лекарства'
          ? EventsGrid(
              categoriesForEventsScreen,
              1,
            )
          : _pages[ScreenNumber.number_of_screen % 4]['page']),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.black,
        onTap: _selectPage,
        backgroundColor: Theme.of(context).primaryColor,
        currentIndex: ScreenNumber.number_of_screen % 4,
        type: BottomNavigationBarType.shifting,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            label: 'Лекарства',
            icon: Icon(Icons.event),
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            label: 'Профиль',
            icon: Icon(Icons.account_box_outlined),
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            label: 'Моя семья',
            icon: Icon(Icons.family_restroom),
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            label: 'Настройки',
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      floatingActionButton:
          (_pages[ScreenNumber.number_of_screen % 4]['title'] == 'Лекарства')
              ? Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                          ),
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        height: 50,
                        child: IconButton(
                          icon: Icon(Icons.add),
                          color: Theme.of(context).primaryColor,
                          onPressed: createFunc,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                )
              : null,
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void callDateChooseScreen() async {
    String newDate = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => DateChoose(
          newTime: selecDate,
        ).build(context),
      ),
    );
    setState(() {
      selecDate = newDate;
    });
  }

  void callMoneyScreen() async {
    List<String> prices = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => MoneyChoose(
          minPrice: newMinPrice,
          maxPrice: newMaxPrice,
        ).build(context),
      ),
    ) as List<String>;
    setState(() {
      newMinPrice = int.parse(prices[0]);
      newMaxPrice = int.parse(prices[1]);
      print('newMinPrice ${newMinPrice}');
      print('newMaxPrice ${newMaxPrice}');
    });
  }

  // Future<void> callPopUp() async {
  //   dynamic newCategories = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (BuildContext context) => PopUpDialog(
  //         oldCategories: categoriesForEventsScreen,
  //       ).build(context),
  //     ),
  //   ) as Map<String, dynamic>;
  //   setFilters(newCategories);
  // }

  void setFilters(Map<String, dynamic> newCategories) {
    setState(() {
      for (String key in newCategories.keys) {
        categoriesForEventsScreen[key] = newCategories[key];
      }
    });
  }
}
