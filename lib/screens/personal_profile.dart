import 'package:flutter/material.dart';
import '../providers/profile.dart';
import '../providers/profiles.dart';
import '../widgets/raiting_bar.dart';
import 'package:provider/provider.dart';
import '../widgets/build_detail_field.dart';
import '/screens/splash_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PersonalProfileScreen extends StatefulWidget {
  static const routeName = '/persprof';

  @override
  State<PersonalProfileScreen> createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen> {
  bool isLoading = false;
  String creatorUsername = 'Организатор';
  Profile curProfile;
  String _uploadedFileURL;

  void setUsername(String profileId) async {
    setState(() {
      isLoading = true;
    });
    Profile profile = await Provider.of<Profiles>(
      context,
      listen: false,
    ).findById(profileId);
    curProfile = profile;
    setState(() {
      if (profile.username == null) {
        creatorUsername = 'anonymous';
      } else {
        creatorUsername = profile.username;
      }
      haveFinalData = true;
      isLoading = false;
    });
    print("FTTTNNNN $creatorUsername");
  }

  void setUser(String profileId) async {
    await setUsername(profileId);
  }

  bool haveFinalData = false;

  void setNewRating(int rating) async {
    int curRating = curProfile.rating;
    int newRating = ((curRating + rating) / 2).round();
    setState(() {
      curProfile.rating = newRating;
    });
    print('CALL UPDATE');
    await Provider.of<Profiles>(context, listen: false)
        .updateProfile(curProfile.id, curProfile);
  }

  void uploadPhoto(String id) {
    FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child(id + '.jpg')
        .getDownloadURL()
        .then((value) {
      setState(() {
        _uploadedFileURL = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String profileId = ModalRoute.of(context).settings.arguments as String;
    if (!haveFinalData) {
      uploadPhoto(profileId);
      setUser(profileId);
      haveFinalData = true;
    }
    if (isLoading) {
      return SplashScreen();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Row(
          children: [
            Container(
              height: 25,
              child: Text(
                'Создатель',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              height: 20,
              child: Image.asset('assets/images/palm-tree.png',
                  fit: BoxFit.fill, height: 80, width: 25, scale: 0.8),
            ),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(bottom: 10),
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.secondary,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Align however you like (i.e .centerRight, centerLeft)
              DetailField("Чужой_профиль", creatorUsername,
                  idUser: curProfile.id),
              DetailField("Имя", curProfile.firstName),
              DetailField("Фамилия", curProfile.lastName),
              DetailField("Возраст", curProfile.age),
              DetailField("Пол", curProfile.male),
              DetailField("Адрес пользователя", curProfile.address.title),
              // DetailField("Рейтинг пользователя", curProfile.rating.toString()),
              // if (Profiles.curProfileId != profileId)
              //   Container(
              //     width: 350,
              //     padding: EdgeInsets.all(10),
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.all(
              //         Radius.circular(10),
              //       ),
              //       border: Border.all(
              //         color: Theme.of(context).primaryColor,
              //       ),
              //     ),
              //     margin: EdgeInsets.only(top: 10),
              //     child: RatingBarWidget(
              //       onRatingChanged: (rating) {
              //         var j = rating.round();
              //         print('jjjj ${j.runtimeType}');
              //         print('NEW RATING ${j}');
              //         setNewRating(j);
              //       },
              //       initialRating: 0,
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
