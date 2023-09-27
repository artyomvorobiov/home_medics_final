import 'package:nope/providers/address.dart';
import 'package:nope/providers/profile.dart';

import '../providers/profiles.dart';
import '/screens/search_places_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../widgets/address_widget.dart';
import '../widgets/date_widget.dart';

import '../providers/drug.dart';
import '../providers/drugs.dart';
import '../widgets/image_input.dart';

class CreatingEventScreen extends StatefulWidget {
  static const routeName = '/creating-event';

  const CreatingEventScreen({Key key}) : super(key: key);

  @override
  State<CreatingEventScreen> createState() => _CreatingEventScreenState();
}

class _CreatingEventScreenState extends State<CreatingEventScreen> {
  SearchPlacesScreen searchPlacesScreen = SearchPlacesScreen();
  List<String> measurementUnits = ['мл', 'таблеток', 'саше'];
  // Address curInitAdr;
  final _form = GlobalKey<FormState>();
  final _priceFocusNode = FocusNode();
  List<dynamic> curComments;
  List<dynamic> curCommentators;
  Map<String, dynamic> redactedEvent = {
    'id': null,
    'dateTime': '',
    'dayTillExp': '',
    'description': '',
    'name': '',
    'price': '',
    'address': '',
    'extraInformation': '',
    'creatorId': '',
    'familyID': '',
    'show': '',
  };
  bool showDateTime = false;
  bool showDrug = false;
  Drug drug;
  bool alreadyBuild = false;
  Map<String, dynamic> oldCategories;
  Set<Marker> markersList = {};

  GoogleMapController googleMapController;

  int screen;
  bool u = false;
  Address selectedAddress;
  String _salutation;
  Profile _editedProfile = Profiles.curProfile;

  // 1 - с центрального
  // 2 - при создании
  // 3 - при редактировании

  void copyData() {
    drug = Drug(
      id: redactedEvent['id'],
      dateTime: redactedEvent['dateTime'],
      dayTillExp: redactedEvent['dayTillExp'],
      description: redactedEvent['description'],
      name: redactedEvent['name'],
      price: redactedEvent['price'],
      address: redactedEvent['address'],
      extraInformation: redactedEvent['extraInformation'],
      creatorId: redactedEvent['creatorId'],
      familyID: redactedEvent['familyID'],
      show: redactedEvent['show'],

      // categories: redactedEvent['categories'],
    );
  }

  // bool categoriesCorrect() {
  //   for (String category in drug.categories.keys) {
  //     if (event.categories[category] == true) {
  //       return true;
  //     }
  //   }
  //   return false;
  // }

  Future<bool> validate() async {
    // if (event.dateTime != '' && event.dateTime != null)
    if (selectedAddress == null && drug.id == null) {
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Ошибка!'),
          content: Text(
              'Выберите адрес! А если нет доступных адресов, то введите свой в личных данных!'),
          actions: <Widget>[
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
      return false;
    }
    if (Profiles.curProfile.familyId != '' &&
        Profiles.curProfile.familyId != null) {
      if (drug.description != '' && drug.description != null) {
        if (drug.name != '' && drug.name != null) {
          if (drug.address.title != '' && drug.address != null) {
            // if (drug.extraInformation != '' && drug.extraInformation != null) {
            return true;
            // }
            // print('ExtraInfo not input');
            // print(drug.extraInformation);
          }
        }
        print('Price not input');
      }
      print('Name not input');
    }
    print('Введите код семьи в личных данных');

    await showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ошибка!'),
        content: Text(
            'Вы не прошли валидацию. Какое-то из полей осталось пустым, или Вы не ввели код семьи в личных данных!'),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
    return false;
  }

  List<Address> getAddressListWithFamilyId(String familyId) {
    // Замените 'familyId' на фактическое поле семьи в ваших профилях
    final List<Profile> profiles = Provider.of<Profiles>(context).profiles;
    // print("PROFILESSSSS $profiles");
    final List<Address> addresses = [];

    for (var profile in profiles) {
      if (profile.familyId == familyId) {
        addresses.add(profile.address);
      }
    }
    print("PROFILESSSSS");
    print(addresses[0].title);

    return addresses;
  }

  Future<void> _saveForm() async {
    print(redactedEvent['address']);
    redactedEvent['show'] = showDrug;
    copyData();
    _form.currentState.save();

    if (!await validate()) {
      return;
    }
    try {
      if (drug.address.title != '' && drug.address != null) {
        drug.comments = curComments;
        drug.commentators = curCommentators;
        if (drug.id != null) {
          await Provider.of<Drugs>(context, listen: false)
              .updateEvent(drug.id, drug);
        } else {
          await Provider.of<Drugs>(context, listen: false).addEvent(drug);
          // await Provider.of<Drugs>(context, listen: false).fetchAndSetEvents();
        }
      }
    } catch (error) {
      print("ERROR $error");
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text('Something went wrong.'),
          actions: <Widget>[
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    }

    Navigator.of(context).pop();
  }

  Widget makeField(
    String curInitialValue,
    String curLabelText,
    String fieldName, {
    List<Address> addressList, // Параметр addressList сделан опциональным
  }) {
    // print("PPPPPPP $addressList");
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        border: Border.all(
          color: Theme.of(context).primaryColor,
        ),
      ),
      child: (fieldName == 'address')
          ? DropdownButtonFormField<Address>(
              isExpanded: true,
              items: addressList.map((address) {
                return DropdownMenuItem<Address>(
                  value: address,
                  child: Text(
                    address.title,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedAddress =
                      newValue; // Обновите selectedAddress при выборе адреса
                  redactedEvent['address'] = newValue;

                  copyData();
                });
              },
              value:
                  selectedAddress, // Используйте curInitialValue в качестве начального значения
              style: TextStyle(
                overflow: TextOverflow.ellipsis,
                color: Theme.of(context).primaryColor,
              ),
              decoration: InputDecoration(
                labelText: curLabelText,
                labelStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            )
          :
          //  (fieldName == 'address')
          //     ? AddressWidget(drug, redactedEvent)
          (fieldName == 'dateTime')
              ? DateWidget(drug, redactedEvent)
              // : (fieldName == 'categories')
              //     ? CategoriesWidget(drug, redactedEvent)
              : (fieldName == 'price' || fieldName == 'dayTillExp')
                  ? TextFormField(
                      keyboardType: TextInputType.number,
                      initialValue: curInitialValue,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                      decoration: InputDecoration(
                        labelText: curLabelText,
                        labelStyle:
                            TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      textInputAction: TextInputAction.next,
                      // focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: ((value) =>
                          value.isEmpty ? 'Please provide a name' : null),
                      onSaved: (value) {
                        redactedEvent[fieldName] = value;
                        copyData();
                      })
                  : (fieldName == 'description')
                      ? DropdownButtonFormField<String>(
                          items: measurementUnits.map((unit) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              redactedEvent['description'] = newValue;
                              _salutation = newValue;
                            });
                          },
                          value: _salutation,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                          decoration: InputDecoration(
                            labelText: curLabelText,
                            labelStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      : TextFormField(
                          initialValue: curInitialValue,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                          decoration: InputDecoration(
                            labelText: curLabelText,
                            labelStyle: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                          textInputAction: TextInputAction.next,
                          // focusNode: _priceFocusNode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_priceFocusNode);
                          },
                          validator: ((value) =>
                              value.isEmpty ? 'Please provide a name' : null),
                          onSaved: (value) {
                            redactedEvent[fieldName] = value;
                            copyData();
                          },
                        ),
    );
  }

  void copyStartValues(Drug drug) {
    redactedEvent['id'] = drug.id;
    redactedEvent['dateTime'] = drug.dateTime;
    redactedEvent['dayTillExp'] = drug.dayTillExp;
    redactedEvent['description'] = drug.description;
    redactedEvent['name'] = drug.name;
    redactedEvent['price'] = drug.price;
    redactedEvent['address'] = drug.address;
    redactedEvent['extraInformation'] = drug.extraInformation;
    redactedEvent['creatorId'] = drug.creatorId;
    redactedEvent['familyID'] = drug.familyID;
    redactedEvent['isFavorite'] = drug.isFavorite;
    redactedEvent['show'] = drug.show;
    showDrug = (drug.show == '' || drug.show == null) ? false : drug.show;
  }

  Future<void> _showSaveConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Вы уверены что хотите выйти?'),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Да',
              style: TextStyle(
                // fontSize: 25,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).primaryColor,
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Подтверждаем сохранение
            },
          ),
          TextButton(
            child: Text(
              'Нет',
              style: TextStyle(
                // fontSize: 25,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).primaryColor,
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop(); // Отменяем сохранение
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!alreadyBuild) {
      drug = ModalRoute.of(context).settings.arguments as Drug;
      curComments = drug.comments;
      curCommentators = drug.commentators;
      copyStartValues(drug);
      alreadyBuild = true;
    }
    final List<Address> familyAddresses =
        getAddressListWithFamilyId(Profiles.curProfile.familyId);
    // print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
    // print(familyAddresses[0].title);
    return WillPopScope(
      // Обработчик нажатия кнопки "Назад"
      onWillPop: () async {
        // Вызываем метод для отображения диалогового окна перед выходом
        _showSaveConfirmationDialog();
        return false; // Возвращаем false, чтобы предотвратить нажатие кнопки "Назад"
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Row(children: [
              Text('Добавление лекарства',
                  style: TextStyle(color: Colors.black)),
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.height * 0.03),
                //color: Color.fromARGB(255, 2, 55, 69),
                child: IconButton(onPressed: _saveForm, icon: Icon(Icons.save)),
              ),
            ])),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            //color: Color.fromARGB(255, 2, 55, 69),
            child: Column(
              children: <Widget>[
                // ImageInput(event, redactedEvent),
                // SizedBox(height: 20),
                // // LocationInput(_selectPlace),
                // SizedBox(height: 20),
                Container(
                  // color: Color.fromARGB(255, 2, 55, 69),
                  child: Form(
                    key: _form,
                    child: Column(
                      children: <Widget>[
                        makeField(drug.name, 'Название', 'name'),
                        makeField(drug.price, 'Количество', 'price'),
                        makeField(drug.description, 'Измерение', 'description'),
                        makeField(
                            drug.dateTime == null
                                ? ''
                                : drug.dateTime.toString(),
                            'Время приема',
                            'dateTime'),
                        makeField(
                            drug.dayTillExp,
                            'За сколько дней до конца срока годности предупредить',
                            'dayTillExp'),
                        makeField(
                          "", // Используйте selectedAddress в качестве начального значения
                          'Адрес', // Метка для поля
                          'address',
                          addressList: familyAddresses,
                          // Список адресов для DropdownButtonFormField
                        ),
                        makeField(drug.extraInformation, 'Комментарий',
                            'extraInformation'),
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.height * 0.35,
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              child: Text(
                                'Лекарство доступно для всей семьи',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                            Switch(
                              value: showDrug,
                              onChanged: (newValue) {
                                setState(() {
                                  showDrug = newValue;
                                  redactedEvent['show'] = newValue
                                      ? true
                                      : false; // Обновляем значение в redactedEvent
                                });
                              },
                              activeTrackColor: Theme.of(context).primaryColor,
                              activeColor: Colors.white,
                            ),
                          ],
                        ),
                        // makeField('', '', 'categories'),
                        // Container(
                        //   child: TextButton(
                        //     style: ButtonStyle(
                        //         padding: MaterialStateProperty.all<EdgeInsets>(
                        //             EdgeInsets.all(25)),
                        //         shape: MaterialStateProperty.all(
                        //             RoundedRectangleBorder(
                        //                 side: BorderSide(
                        //                   color: Theme.of(context).primaryColor,
                        //                   width: 1,
                        //                 ),
                        //                 borderRadius:
                        //                     BorderRadius.circular(20)))),
                        //     child: Text(
                        //       "Сохранить",
                        //       style: TextStyle(
                        //         fontSize: 19,
                        //         color: Theme.of(context).primaryColor,
                        //       ),
                        //     ),
                        //     onPressed: _saveForm,
                        //   ),
                        // ),
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
}
