import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile.dart';
import '../providers/profiles.dart';
import '../screens/personal_profile.dart';

// ignore: must_be_immutable
class CommentItem extends StatefulWidget {
  String commentCreatorId;
  String commentText;
  CommentItem(this.commentCreatorId, this.commentText);

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  Profile commentCreatorProfile;

  String commentCreatorUsername = '';
  bool haveFinal = false;

//   String commentCreatorPhoto;
  String _uploadedFileURL;

  void uploadPhoto() {
    FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child(widget.commentCreatorId + '.jpg')
        .getDownloadURL()
        .then((value) {
      setState(() {
        _uploadedFileURL = value;
      });
    });
  }

  void setProfile(BuildContext context) async {
    commentCreatorProfile = await Provider.of<Profiles>(
      context,
      listen: false,
    ).findById(widget.commentCreatorId);
    print("USERNAME ${commentCreatorProfile.username}");
    setState(() {
      commentCreatorUsername = commentCreatorProfile.username;
    });
  }

  void showProfile() async {
    Navigator.of(context).pushNamed(PersonalProfileScreen.routeName,
        arguments: widget.commentCreatorId);
  }

  @override
  Widget build(BuildContext context) {
    print('commentCreatorId ${widget.commentCreatorId}');
    if (!haveFinal) {
      uploadPhoto();
      setProfile(context);
      haveFinal = true;
    }

    return Container(
      width: double.infinity,
      // height: MediaQuery.of(context).size.height * 0.2,
      padding: EdgeInsets.only(bottom: 10, top: 5),
      child: Column(
        children: [
          GestureDetector(
              onTap: showProfile,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: _uploadedFileURL != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(_uploadedFileURL,
                                width:
                                    MediaQuery.of(context).size.height * 0.15,
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                fit: BoxFit.fill),
                          )
                        : Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(50)),
                            width: MediaQuery.of(context).size.height * 0.15,
                            height: MediaQuery.of(context).size.height * 0.15,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.grey[800],
                            ),
                          ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      commentCreatorUsername == null
                          ? 'anonymous'
                          : commentCreatorUsername,
                      style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              )),
          Container(
            child: Text(
              widget.commentText,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Divider(
            color: Theme.of(context).primaryColor,
            thickness: 2,
          ),
        ],
      ),
    );
  }
}
