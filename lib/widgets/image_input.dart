import 'dart:io';

import '../providers/drug.dart';
import '/providers/profiles.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/profile.dart';
import 'package:provider/provider.dart';

class ImageInput extends StatefulWidget {
  Drug curEvent;
  Map<String, dynamic> redactedEvent;

  String futurePath;

  ImageInput(this.curEvent, this.redactedEvent);

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File _storedImage;
  FirebaseStorage storage = FirebaseStorage.instance;

  Future imgFromGallery() async {
    final pickedFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );

    await uploadFile(File(pickedFile.path));
    setState(() {
      print('ASDFG');
      if (pickedFile != null) {
        _storedImage = File(pickedFile.path);
        print('pickedFile.pathnew ${pickedFile.path}');
      } else {
        print('No image selected.');
      }
    });
  }

  Future imgFromCamera() async {
    final pickedFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );

    await uploadFile(File(pickedFile.path));
    setState(() {
      if (pickedFile != null) {
        _storedImage = File(pickedFile.path);
        print('pickedFile.path ${pickedFile.path}');
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadFile(File _storedImage) async {
    print('UPLOADFILE');
    if (_storedImage == null) return;
    Profile curProfile = Profiles.curProfile;
    print('Profiles.curProfile ${Profiles.curProfile}');
    print('curProfile.countOfEvents ${curProfile.countOfEvents}');
    curProfile.countOfEvents++;
    await Provider.of<Profiles>(context, listen: false)
        .updateProfile(curProfile.id, curProfile);
    try {
      var ref = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child(curProfile.id + curProfile.countOfEvents.toString() + '.jpg')
          .putFile(_storedImage);
      var url = await ref.then((res) => res.ref.getDownloadURL());
      // widget.curEvent.imagePath = url;
      widget.redactedEvent['imageUrl'] = url;

      //  print("UUUURRRLLL2 ${widget.curEvent.imagePath}");
      print("URLLLLLL ${url}");
    } catch (e) {
      print('error occured');
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Галерея'),
                  onTap: () {
                    imgFromGallery();
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Камера'),
                onTap: () {
                  imgFromCamera();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 150,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),
          child: _storedImage != null
              ? Image.file(
                  _storedImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
              : Text(
                  'Изображение не выбрано',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
          alignment: Alignment.center,
        ),
        SizedBox(height: 10),
        Expanded(
          child: TextButton.icon(
            icon: Icon(Icons.camera),
            label: Text('Выберите изображение'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
            ),
            onPressed: () => _showPicker(context),
          ),
        ),
      ],
    );
  }
}
