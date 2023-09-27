import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nope/providers/address.dart';
import 'package:uuid/uuid.dart';

import '../providers/drugs.dart';
import '../widgets/address_widget.dart';
import '/providers/profile.dart';
import '/providers/profiles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../widgets/chip.dart';

class PersonalInfoScreen extends StatefulWidget {
  static const routeName = '/personal-info';

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final TextEditingController _familyIdController = TextEditingController();
  bool _dataChanged = false;
  bool generated = false;
  String originalFirstName;
  String originalLastName;
  String originalUsername;
  String originalFamilyId;
  String originalAge;
  String originalMale;
  Profile prof;

  int resultFromMale = -1;
  var value = -1;
  bool test;

  String labelForMaleField = 'Выберите пол';
  bool alreadyUpdated = false;
  final _form = GlobalKey<FormState>();
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  var _isInit = true;
  var _isLoading = false;
  int curAmountOfEvents;
  int curRating;
  Profile _editedProfile;
  String uuid = '';
  String adr;

//   Future<bool> doesNameAlreadyExist(String name) async {
//   final QuerySnapshot result = await Firestore.instance
//     .collection('profile')
//     .where('familyId', isEqualTo: _editedProfile.familyId)
//     .limit(1)
//     .getDocuments();
//   final List<DocumentSnapshot> documents = result.documents;
//   return documents.length == 1;
// }

  Map<String, dynamic> redPersInfo = {
    'id': '',
    'firstName': '',
    'lastName': '',
    'username': '',
    'familyId': '',
    'email': '',
    'age': '',
    'male': '',
    'address': '',
    'creator': false,
    'rating': 0,
  };

  void copyData() {
    _editedProfile = Profile(
        id: redPersInfo['id'],
        firstName: redPersInfo['firstName'],
        lastName: redPersInfo['lastName'],
        username: redPersInfo['username'],
        familyId: redPersInfo['familyId'],
        email: redPersInfo['email'],
        age: redPersInfo['age'],
        male: redPersInfo['male'],
        address: redPersInfo['address'],
        creator: redPersInfo['creator'],
        rating: redPersInfo['rating']);
  }

  Future<void> _saveForm() async {
    String newUsername;
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });

    try {
      newUsername = _editedProfile.familyId;
      _editedProfile.rating = curRating;
      _editedProfile.countOfEvents = curAmountOfEvents;
      final newFamilyId = _editedProfile.familyId;
      print("testtt $test");
      print(test);
      if ((originalFamilyId != newFamilyId) && (!generated)) {
        _editedProfile.creator = false;
        print("originalFamilyId");
        print(originalFamilyId);
        print(_editedProfile.familyId);
      } else if (generated) {
        _editedProfile.creator = true;
      }
      await Provider.of<Profiles>(context, listen: false)
          .updateProfile(_editedProfile.id, _editedProfile);
      print("newFamilyId $newFamilyId");
      // Вызовите метод updateDrugsFamilyId для обновления familyId в лекарствах
      await Provider.of<Drugs>(context, listen: false)
          .updateDrugsFamilyId(newFamilyId);
    } catch (error) {
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text('Something went wrong.'),
          actions: <Widget>[
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop(newUsername);
              },
            ),
          ],
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop(newUsername);
    _dataChanged = false;
  }

  void setStartValues(Profile profile) {
    redPersInfo['id'] = profile.id;
    redPersInfo['firstName'] = profile.firstName;
    redPersInfo['lastName'] = profile.lastName;
    redPersInfo['username'] = profile.username;
    redPersInfo['familyId'] = profile.familyId;
    redPersInfo['email'] = profile.email;
    redPersInfo['age'] = profile.age;
    redPersInfo['male'] = profile.male;
    redPersInfo['address'] = profile.address;
    redPersInfo['creator'] = profile.creator;
    redPersInfo['rating'] = profile.rating;
    _dataChanged = false;
    adr = profile.address.title;
    originalFamilyId = profile.familyId;
    // print("AAAAAAA $adr");
    test = profile.creator;
  }

  Widget persField(String initVal, String labelText, String fieldName) {
    int limit = fieldName == 'username' ? 10 : 100;
    if (fieldName == 'Идентификатор семьи') {
      return Container(
        width: double.infinity,
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
        child: TextFormField(
          inputFormatters: [
            LengthLimitingTextInputFormatter(limit),
          ],
          controller: _familyIdController,
          initialValue: initVal,
          //  maxLength: 10,
          // key: Key(uuid.toString()), // <- Magic!
          // initialValue: uuid.toString(),
          style: TextStyle(color: Theme.of(context).primaryColor),
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(color: Theme.of(context).primaryColor),
          ),
          keyboardType: fieldName == 'age' ? TextInputType.number : null,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            _dataChanged = true;
            FocusScope.of(context).requestFocus(_priceFocusNode);
          },
          validator: ((value) =>
              value.isEmpty ? 'Please provide a name' : null),
          onSaved: (value) {
            redPersInfo[fieldName] = value;
            copyData();
            _dataChanged = true;
            _familyIdController.text = value;
          },
        ),
      );
    } else {
      return Container(
        width: double.infinity,
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
        child: TextFormField(
          inputFormatters: [
            LengthLimitingTextInputFormatter(limit),
          ],
          //  maxLength: 10,
          initialValue: initVal,
          style: TextStyle(color: Theme.of(context).primaryColor),
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(color: Theme.of(context).primaryColor),
          ),
          keyboardType: fieldName == 'age' ? TextInputType.number : null,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            _dataChanged = true;
            FocusScope.of(context).requestFocus(_priceFocusNode);
          },
          validator: ((value) =>
              value.isEmpty ? 'Please provide a name' : null),
          onSaved: (value) {
            redPersInfo[fieldName] = value;
            copyData();
            _dataChanged = true;
          },
        ),
      );
    }
  }

  void update() async {
    _editedProfile = Profiles.curProfile;
    // if (_editedProfile == null) {
    //   await Provider.of<Profiles>(context, listen: false).setCurrentProfile();
    // }
    curAmountOfEvents = _editedProfile.countOfEvents;
    curRating = _editedProfile.rating;
    setStartValues(_editedProfile);
    alreadyUpdated = true;
  }

  @override
  void initState() {
    super.initState();
    if (_editedProfile != null) {
      // Инициализация исходных данных при загрузке экрана
      originalFirstName = _editedProfile.firstName;
      originalLastName = _editedProfile.lastName;
      originalUsername = _editedProfile.username;
      // originalFamilyId = _editedProfile.familyId;
      originalAge = _editedProfile.age;
      originalMale = _editedProfile.male;
      uuid = _editedProfile.familyId; // Установим начальное значение uuid
    }
  }

  // Метод для отображения диалогового окна с подтверждением сохранения данных
  Future<void> _showSaveConfirmationDialog() async {
    print(_dataChanged);
    // Проверяем, были ли изменены данные
    // bool dataChanged = originalFirstName != _editedProfile.firstName ||
    //     originalLastName != _editedProfile.lastName ||
    //     originalUsername != _editedProfile.username ||
    //     originalFamilyId != _editedProfile.familyId ||
    //     originalAge != _editedProfile.age ||
    //     originalMale != _editedProfile.male;

    if (_dataChanged || (adr != _editedProfile.address.title)) {
      print(_editedProfile.address.title);
      print(adr);
      bool saveData = await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Сохранить изменения?'),
          content: Text('Вы внесли изменения. Сохранить данные?'),
          actions: <Widget>[
            TextButton(
              child: Text('Да'),
              onPressed: () {
                Navigator.of(ctx).pop(true); // Подтверждаем сохранение
              },
            ),
            TextButton(
              child: Text('Нет'),
              onPressed: () {
                Navigator.of(ctx).pop(false);
                Navigator.of(context).pop(); // Отменяем сохранение
              },
            ),
          ],
        ),
      );

      if (saveData) {
        // Вызываем метод для сохранения данных
        // redPersInfo['creator'] = test;
        // copyData();
        // print("test $test");
        await Provider.of<Profiles>(context, listen: false).checkIfAdded();
        _saveForm();
      }
    } else {
      // Если данные не были изменены, просто закрываем экран
      Navigator.of(context).pop();
    }
  }

  Widget generateFamilyIdButton() {
    // return Container(
    //   width: double.infinity,
    //   padding: EdgeInsets.all(10),
    //   margin: EdgeInsets.all(10.0),
    //   decoration: BoxDecoration(
    //     borderRadius: BorderRadius.all(
    //       Radius.circular(10),
    //     ),
    //     color: Theme.of(context).primaryColor,
    //     border: Border.all(
    //       color: Theme.of(context).primaryColor,
    //     ),
    //   ),
    //   child:
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      child: Text(
        "Сгенерировать код семьи",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      onPressed: () {
        setState(() {
          uuid = Uuid().v4();
          redPersInfo['familyId'] = uuid;
          test = true;
          generated = true;
          // redPersInfo['creator'] = true;
          originalFamilyId = uuid;
          copyData(); // Генерируем новый код и обновляем состояние
          _dataChanged = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!alreadyUpdated) {
      update();
    }
    String label = 'Выберите пол';
    if (resultFromMale == 0) {
      label = "Мужской";
    } else if (resultFromMale == 1) {
      label = 'Женский';
    }
    redPersInfo['male'] = label == 'Выберите пол' ? _editedProfile.male : label;
    copyData();
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
          title: Text('Личные данные', style: TextStyle(color: Colors.black)),

          /* actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ], */
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                key: _form,
                child: Column(
                  children: <Widget>[
                    persField(_editedProfile.firstName, 'Имя', 'firstName'),
                    persField(_editedProfile.lastName, 'Фамилия', 'lastName'),
                    persField(_editedProfile.username, 'Ник', 'username'),

                    Container(
                      width: double.infinity,
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
                      child: AddressWidget(_editedProfile, redPersInfo),
                    ),

                    // persField(_editedProfile.familyId, 'Идентификатор семьи',
                    //     'familyId'),
                    // Кнопка для генерации кода семьи

                    // Виджет для отображения сгенерированного кода
                    // Container(
                    //   width: double.infinity,
                    //   padding: EdgeInsets.all(10),
                    //   margin: EdgeInsets.all(10.0),
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.all(
                    //       Radius.circular(10),
                    //     ),
                    //     border: Border.all(
                    //       color: Theme.of(context).primaryColor,
                    //     ),
                    //   ),
                    //   child: Text(
                    //     uuid,
                    //     style: TextStyle(
                    //       color: Theme.of(context).primaryColor,
                    //     ),
                    //   ),
                    // ),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      margin: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 8, right: 5),
                            child: Text(
                              'Пол: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints.tightFor(
                                width: MediaQuery.of(context).size.height * 0.3,
                                height:
                                    MediaQuery.of(context).size.height * 0.05),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                side: BorderSide(
                                  width: 1,
                                  color: Theme.of(context).primaryColor,
                                ),
                                elevation: 0,
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                // padding: EdgeInsets.only(right: 240),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                textStyle: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                              // child: Align(
                              //   alignment: Alignment.centerLeft,
                              child: Text(
                                _editedProfile.male == ''
                                    ? 'Выберите пол'
                                    : _editedProfile.male,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              //),
                              onPressed: () {
                                showSmth(context, value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    // persField(_editedProfile.male, 'Пол', 'male'),
                    persField(_editedProfile.age, 'Возраст', 'age'),
                    generateFamilyIdButton(),
                    Container(
                      width: double.infinity,
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
                      child: TextFormField(
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(100),
                        ],
                        //  maxLength: 10,
                        key: Key(uuid), // <- Magic!
                        initialValue:
                            uuid == '' ? _editedProfile.familyId : uuid,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                        decoration: InputDecoration(
                          labelText: 'Код семьи',
                          labelStyle:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        keyboardType:
                            'familyId' == 'age' ? TextInputType.number : null,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          _dataChanged = true;
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        validator: ((value) =>
                            value.isEmpty ? 'Please provide a name' : null),
                        onSaved: (value) {
                          test = false;
                          redPersInfo['familyId'] = value;
                          copyData();
                          _dataChanged = true;
                        },
                      ),
                    ),

                    // Container(
                    //   width: double.infinity,
                    //   padding: EdgeInsets.only(top: 10, bottom: 10),
                    //   margin: EdgeInsets.all(10.0),
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.all(
                    //       Radius.circular(10),
                    //     ),
                    //     border: Border.all(
                    //       color: Theme.of(context).primaryColor,
                    //     ),
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       Container(
                    //         padding: EdgeInsets.only(left: 8, right: 5),
                    //         child: Text(
                    //           'Рейтинг: ',
                    //           style: TextStyle(
                    //             fontWeight: FontWeight.w400,
                    //             fontSize: 18,
                    //             color: Theme.of(context).primaryColor,
                    //           ),
                    //         ),
                    //       ),
                    //       Container(
                    //         width: MediaQuery.of(context).size.height * 0.02,
                    //         height: MediaQuery.of(context).size.height * 0.05,
                    //         child: Align(
                    //           alignment: Alignment.centerLeft,
                    //           child: Text(
                    //             _editedProfile.rating == ''
                    //                 ? 'У вас нет рейтинга'
                    //                 : _editedProfile.rating.toString(),
                    //             style: TextStyle(
                    //               fontWeight: FontWeight.w400,
                    //               fontSize: 18,
                    //               color: Theme.of(context).primaryColor,
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //       Container(
                    //         width: MediaQuery.of(context).size.height * 0.02,
                    //         height: MediaQuery.of(context).size.height * 0.05,
                    //         child: Align(
                    //           alignment: Alignment.centerLeft,
                    //           child: Icon(
                    //             Icons.star,
                    //             color: Theme.of(context).primaryColor,
                    //             size: 25.0,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
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
                    //                 borderRadius: BorderRadius.circular(20)))),
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
          ),
        ),
      ),
    );
  }

  void showSmth(BuildContext context, int value) async {
    Choise choise = Choise(value);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          // scrollable: true,
          title: Container(
            color: Theme.of(context).primaryColor,
            child: Row(
              children: [
                Container(
                  height: 40,
                  margin: const EdgeInsets.all(15.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 22,
                        child: Text(
                          'Домашняя аптечка',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // Container(
                      //   height: 22,
                      //   child: Image.asset('assets/images/palm-tree.png',
                      //       fit: BoxFit.fill,
                      //       height: 80,
                      //       width: 25,
                      //       scale: 0.8),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          content: Container(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 80,
                      child: Text(
                        "Выберите свой пол",
                        style: TextStyle(
                          fontSize: 19,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    choise,
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                "Применить",
                style: TextStyle(
                  fontSize: 19,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onPressed: () {
                setState(() {
                  resultFromMale = choise.value;
                  _dataChanged = true;
                  Navigator.of(context).pop(resultFromMale);
                });
              },
            ),
            TextButton(
              child: Text(
                "Закрыть",
                style: TextStyle(
                  fontSize: 19,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
