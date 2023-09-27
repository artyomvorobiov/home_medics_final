import '../providers/profile.dart';
import '../providers/profiles.dart';
import '../widgets/raiting_bar.dart';
import '../providers/drug.dart';
import 'creating_drug_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/build_detail_field.dart';
import '../providers/auth.dart';
import '../providers/drugs.dart';
import 'comments_screen.dart';

class EventDetailScreen extends StatefulWidget {
  static const routeName = '/event-detail';

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool isFavorite = false;
  String creatorUsername = 'Организатор';
  String currentUserId;
  Drug loadedEvent;
  void setUsername(String profileId) async {
    Profile profile = await Provider.of<Profiles>(
      context,
      listen: false,
    ).findById(profileId);
    setState(() {
      creatorUsername = profile.username;
      haveFinalData = true;
    });
    print("FTTTNNNN $creatorUsername");
  }

  void setUser(String profileId) async {
    await setUsername(profileId);
  }

  void openComments() async {
    print('loadedEvent.comments ${loadedEvent.comments}');
    await Navigator.of(context).pushNamed(
      CommentsScreen.routeName,
      arguments: {loadedEvent.comments, loadedEvent.commentators, loadedEvent},
    );
  }

  bool haveFinalData = false;
  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<Auth>(context, listen: false);
    final drugId =
        ModalRoute.of(context).settings.arguments as String; // is the id!
    loadedEvent = Provider.of<Drugs>(
      context,
      listen: false,
    ).findById(drugId);

    if (!haveFinalData) {
      final profileId = loadedEvent.profileId;
      // currentUserId = profileId;
      // print('currentUserId ${currentUserId}');
      setUser(profileId);
    }

    // loadedEvent.output(loadedEvent);

    bool isEventAvailableToEdit =
        (loadedEvent.familyID == Profiles.curProfile.familyId) ? true : false;
    bool haveDelete = false;

    void deleteEvent(Drug deleteEvent) async {
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).primaryColor,
          // title: Text('Choose varient!'),
          content: Text(
            'Вы уверены, что хотите удалить лекарство?',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Container(
                // color: Theme.of(context).colorScheme.secondary,
                child: Text(
                  'Нет',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              onPressed: () {
                haveDelete = false;
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              child: Container(
                // color: Theme.of(context).colorScheme.secondary,
                child: Text(
                  'Да',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              onPressed: () async {
                await Provider.of<Drugs>(context, listen: false)
                    .deleteEvent(deleteEvent.id);
                haveDelete = true;
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    }

    void delEvent() async {
      await deleteEvent(loadedEvent);
      if (haveDelete == true) {
        Navigator.of(context).pop();
      }
    }

    // Provider.of<Event>(context, listen: false)
    //     .getOldFavStatus(authData.token, authData.userId, loadedEvent.id);
    void putLike() async {
      await Provider.of<Drug>(context, listen: false).toggleFavoriteStatus(
          authData.token,
          authData.userId,
          loadedEvent.id,
          !loadedEvent.isFavorite);
      setState(() {
        loadedEvent.isFavorite = !loadedEvent.isFavorite;
      });
    }

    print('loadedEvent.profileId ${loadedEvent.profileId}');
    // print('currentUserId${currentUserId}');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Row(
          children: [
            Text(loadedEvent.name, style: TextStyle(color: Colors.black)),
            if (isEventAvailableToEdit)
              Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.height * 0.12),
                      child: IconButton(
                        icon: Icon(Icons.edit, color: Colors.black),
                        onPressed: () {
                          func(loadedEvent);
                        },
                      ),
                    ),
                    Container(
                      // padding: EdgeInsets.only(left: 170),
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.black),
                        onPressed: () {
                          delEvent();
                        },
                      ),
                    ),
                  ])
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(bottom: 6),
        height: double.infinity,
        width: double.infinity,
        color: Theme.of(context).colorScheme.secondary,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Container(
              //   child: Text(
              //     loadedEvent.name,
              //     style: TextStyle(
              //       fontSize: 35,
              //       fontWeight: FontWeight.w800,
              //       color: Theme.of(context).primaryColor,
              //     ),
              //   ),
              // ),
              DetailField(
                "Адрес",
                loadedEvent.address.title,
                address: loadedEvent.address,
              ),
              DetailField("Срок годности", loadedEvent.dateTime.toString()),
              // DetailField(
              // "Количество дней Предупреждения за ", loadedEvent.dayTillExp),
              DetailField("Количество", loadedEvent.price),
              DetailField("Измерение", loadedEvent.description),
              DetailField(
                  "Дополнительная информация", loadedEvent.extraInformation),
              // DetailField("Создатель", creatorUsername,
              //     idUser: loadedEvent.profileId),
              // Container(
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
              //     margin: EdgeInsets.only(top: 10.0),
              //     child: TextButton(
              //       onPressed: openComments,
              //       child: Text(
              //         'Комментарии',
              //         style: TextStyle(
              //           fontSize: 28,
              //           fontWeight: FontWeight.w800,
              //           color: Theme.of(context).primaryColor,
              //         ),
              //         textAlign: TextAlign.center,
              //       ),
              //     )),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: loadedEvent.isFavorite
            ? Icon(
                Icons.favorite,
                color: Theme.of(context).primaryColor,
              )
            : Icon(
                Icons.favorite_border,
                color: Theme.of(context).primaryColor,
              ),
        onPressed: putLike,
      ),
    );
  }

  Future<void> func(Drug loadedEvent) async {
    await Navigator.of(context)
        .pushNamed(CreatingEventScreen.routeName, arguments: loadedEvent);
    setState(() {});
  }
}
