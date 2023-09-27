import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../providers/address.dart';
import '../providers/drug.dart';
import '../providers/drugs.dart';
import '../widgets/profile_field.dart';
import '/providers/profiles.dart';
import 'drugs_screen.dart';
import '/screens/personal_info_screen.dart';
import '/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'favorite_drugs_screen.dart';

import '../providers/auth.dart';
import 'creating_drug_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool wasUpdated = false;
  FirebaseStorage storage = FirebaseStorage.instance;
  String username =
      (Profiles.curProfile == null || Profiles.curProfile.username == '')
          ? 'Никнейм'
          : Profiles.curProfile.username;
  String familyID =
      (Profiles.curProfile == null || Profiles.curProfile.familyId == '')
          ? 'Введите ID семьи'
          : Profiles.curProfile.familyId;

  void personalFunc(BuildContext context) async {
    String newUsername = await Navigator.of(context).pushNamed(
      PersonalInfoScreen.routeName,
    ) as String;
    if (newUsername != null && newUsername != '') {
      setState(() {
        familyID = newUsername;
      });
    }
  }

  void createFunc() async {
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
      Provider.of<Drugs>(context, listen: false).fetchAndSetEvents(true);
    });
  }

  void _showFamilyCodeInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Информация о коде семьи",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          content: Text(
            "Это код Вашей семьи, если другие пользователи введут его в личных данных, то они присоединятся к Вашей семье и будут видеть и добавлять лекарства в общую аптечку.",
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Закрыть",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      color: Theme.of(context).colorScheme.secondary,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment
                  .center, // Выравнивание по центру как по горизонтали, так и по вертикали
              child: IconButton(
                icon: Icon(
                  Icons.info_outline, // Значок информации
                  size: 30.0,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  // Отображение всплывающего окна с информацией о коде семьи
                  _showFamilyCodeInfo(context);
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              child: GestureDetector(
                onLongPress: () {
                  // Копирование текста на долгое нажатие
                  Clipboard.setData(ClipboardData(text: familyID));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Код семьи скопирован в буфер обмена"),
                  ));
                },
                child: Container(
                  width: MediaQuery.of(context).size.height * 0.33,
                  height: MediaQuery.of(context).size.height * 0.15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                    // border: Border.all(
                    //   color: Theme.of(context).primaryColor,
                    // ),
                  ),
                  // padding: EdgeInsets.all(10),
                  // margin: EdgeInsets.only(left: 28.0),
                  child: Text(
                    familyID,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              // Container(
              //   width: MediaQuery.of(context).size.height * 0.28,
              //   height: MediaQuery.of(context).size.height * 0.10,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.all(
              //       Radius.circular(20),
              //     ),
              //     border: Border.all(
              //       color: Theme.of(context).primaryColor,
              //     ),
              //   ),
              //   padding: EdgeInsets.all(20),
              //   margin: EdgeInsets.only(left: 25.0),
              //   child: ElevatedButton(
              //     child: Text(
              //       "Сгенерировать код семьи",
              //       style: TextStyle(
              //         fontSize: 26,
              //         fontWeight: FontWeight.w400,
              //         color: Theme.of(context).primaryColor,
              //       ),
              //     ),
              //     onPressed: () {
              //       String uuid = Uuid().v4();
              //       print(uuid);
              //     },
              //   ),
              // )
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
                  color: Theme.of(context).primaryColor,
                ),
              ),
              margin: EdgeInsets.only(top: 10.0),
              child: Align(
                alignment: Alignment
                    .center, // Выравнивание по центру как по горизонтали, так и по вертикали
                child: InkWell(
                  onTap: () => personalFunc(
                      context), // Переход на страницу личных данных
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .start, // Выравнивание по центру по горизонтали
                    children: [
                      Icon(
                        Icons.person, // Иконка "Личные данные"
                        size: 30.0,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Личные данные",
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
                  onTap: () => Navigator.of(context).pushNamed(
                    EventsScreen.routeName,
                  ), // Переход на страницу личных данных
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .start, // Выравнивание по центру по горизонтали
                    children: [
                      Icon(
                        Icons.pan_tool,
                        size: 30.0,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Мои лекарства",
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
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(FavoriteEventsScreen.routeName);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .start, // Выравнивание по центру по горизонтали
                    children: [
                      Icon(
                        Icons.favorite, // Иконка "Личные данные"
                        size: 30.0,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Избранные лекарства",
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
            // Container(
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.all(
            //       Radius.circular(10),
            //     ),
            //     border: Border.all(
            //       color: Theme.of(context).primaryColor,
            //     ),
            //   ),
            //   // alignment: Alignment.center,
            //   margin: EdgeInsets.only(top: 10.0),
            //   child: ConstrainedBox(
            //     constraints: BoxConstraints.tightFor(
            //         width: MediaQuery.of(context).size.height * 0.4,
            //         height: 70),
            //     // child: ElevatedButton(
            //     //   style: ElevatedButton.styleFrom(
            //     //     backgroundColor: Theme.of(context).colorScheme.secondary,
            //     //     // padding: EdgeInsets.all(20),
            //     //     shape: RoundedRectangleBorder(
            //     //       borderRadius: BorderRadius.circular(20),
            //     //     ),
            //     //     textStyle:
            //     //         TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            //     //   ),
            //     //   child: Text("Добавить лекарство",
            //     //       style: TextStyle(
            //     //         fontSize: 22,
            //     //         color: Theme.of(context).primaryColor,
            //     //       )),
            //     //   onPressed: createFunc,
            //     // ),
            //   ),
            // ),
            // ProfileField("Избранные лекарства", () {
            //   Navigator.of(context).pushNamed(FavoriteEventsScreen.routeName);
            // }),
            // ProfileField("Настройки", () {
            //   Navigator.of(context).pushNamed(SettingsScreen.routeName);
            // }),
            // ProfileField("Выйти из аккаунта", () {
            //   Navigator.of(context).pushReplacementNamed('/');
            //   Provider.of<Auth>(context, listen: false).logout();
            // }),
          ],
        ),
      ),
    );
  }
}
