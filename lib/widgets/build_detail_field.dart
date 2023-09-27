import '/providers/address.dart';
import '/screens/main_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/screen_number.dart';

import '../providers/profiles.dart';
import '../screens/personal_profile.dart';
import '../screens/settings_screen.dart';

class DetailField extends StatefulWidget {
  final String fieldName;
  final String fieldValue;
  final Address address;
  String idUser;

  DetailField(this.fieldName, this.fieldValue,
      {this.idUser = null, this.address = null});

  @override
  State<DetailField> createState() => _DetailFieldState();
}

class _DetailFieldState extends State<DetailField> {
  String _uploadedFileURL;
  bool wasUploaded = false;
  void uploadPhoto() {
    FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child(widget.idUser + '.jpg')
        .getDownloadURL()
        .then((value) {
      setState(() {
        _uploadedFileURL = value;
        wasUploaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fieldName == 'Организатор' ||
        widget.fieldName == 'Чужой_профиль') {
      if (!wasUploaded) {
        print('idUser${widget.idUser}');
        uploadPhoto();
      }
    }

    return widget.fieldName == 'Адрес'
        ? TextButton(
            child: Container(
              width: 350,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              margin: EdgeInsets.only(top: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment
                        .center, // Align however you like (i.e .centerRight, centerLeft)
                    child: Text(
                      widget.fieldName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).primaryColor,
                    thickness: 2,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 3.0),
                    child: Align(
                      alignment: Alignment
                          .center, // Align however you like (i.e .centerRight, centerLeft)
                      child: Text(
                        widget.fieldValue,
                        style: TextStyle(
                          fontSize: 22,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // onPressed: () {
            //   Navigator.pop(context);
            //   Provider.of<ScreenNumber>(context, listen: false).changeNumber();
            //   MainScreen.address = widget.address;
            // },
          )
        : (widget.fieldName == 'Создатель')
            ? Container(
                width: 350,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                margin: EdgeInsets.only(top: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment
                          .center, // Align however you like (i.e .centerRight, centerLeft)
                      child: Text(
                        widget.fieldName,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Divider(
                      color: Theme.of(context).primaryColor,
                      thickness: 2,
                    ),
                    TextButton(
                      child: Row(
                        children: [
                          // CircleAvatar(
                          //   radius: 55,
                          //   backgroundColor: Theme.of(context).primaryColor,
                          //   child: _uploadedFileURL != null
                          //       ? ClipRRect(
                          //           borderRadius: BorderRadius.circular(50),
                          //           child: Image.network(_uploadedFileURL,
                          //               width:
                          //                   MediaQuery.of(context).size.height *
                          //                       0.35,
                          //               height:
                          //                   MediaQuery.of(context).size.height *
                          //                       0.35,
                          //               fit: BoxFit.fill),
                          //         )
                          //       : Container(
                          //           decoration: BoxDecoration(
                          //               color: Colors.grey[200],
                          //               borderRadius:
                          //                   BorderRadius.circular(50)),
                          //           width: MediaQuery.of(context).size.height *
                          //               0.35,
                          //           height: MediaQuery.of(context).size.height *
                          //               0.35,
                          //           child: Icon(
                          //             Icons.camera_alt,
                          //             color: Colors.grey[800],
                          //           ),
                          //         ),
                          // ),
                          Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              widget.fieldValue,
                              style: TextStyle(
                                fontSize: 22,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                            PersonalProfileScreen.routeName,
                            arguments: widget.idUser);
                      },
                    )
                  ],
                ),
              )
            : (widget.fieldName == 'Чужой_профиль')
                ? Container(
                    width: 350,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    margin: EdgeInsets.only(top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment
                              .center, // Align however you like (i.e .centerRight, centerLeft)
                          child: Text(
                            widget.fieldValue,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Divider(
                          color: Theme.of(context).primaryColor,
                          thickness: 2,
                        ),
                        Row(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                child: CircleAvatar(
                                  radius: 85,
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  child: _uploadedFileURL != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: Image.network(_uploadedFileURL,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.45,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.45,
                                              fit: BoxFit.fill),
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.45,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.45,
                                          child: Icon(
                                            Icons.camera_alt,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                ),
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.height *
                                        0.09),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                : Container(
                    width: 350,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    margin: EdgeInsets.only(top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment
                              .center, // Align however you like (i.e .centerRight, centerLeft)
                          child: Text(
                            widget.fieldName,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Divider(
                          color: Theme.of(context).primaryColor,
                          thickness: 2,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 3.0),
                          child: Align(
                            alignment: Alignment
                                .center, // Align however you like (i.e .centerRight, centerLeft)
                            child: Text(
                              widget.fieldValue,
                              style: TextStyle(
                                fontSize: 22,
                                color: Theme.of(context).primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
  }
}
