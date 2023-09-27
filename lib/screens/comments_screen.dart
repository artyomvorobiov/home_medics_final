import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drug.dart';
import '../providers/drugs.dart';
import '../providers/profiles.dart';
import '../widgets/comment_item.dart';

class CommentsScreen extends StatefulWidget {
  static const routeName = 'comments-screen';

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

void saveComment(BuildContext context, Drug curEvent) async {
  await Provider.of<Drugs>(context, listen: false)
      .updateEvent(curEvent.id, curEvent);
}

class _CommentsScreenState extends State<CommentsScreen> {
  List<dynamic> newComments;
  List<dynamic> newCommentators;
  String newComment;
  Drug curEvent;
  TextEditingController _textEditingController = TextEditingController();
  var crossAxisCount = 1;
  void setNewComments(String newCommentText) {
    if (newCommentText != '') {
      String curId = Profiles.curProfileId;
      print('curId ${curId}');
      newCommentators.add(curId);
      curEvent.commentators = newCommentators;
      print('newCommentText ${newCommentText}');
      newComments.add(newCommentText);
      curEvent.comments = newComments;
      saveComment(context, curEvent);
      setState(() {
        newComment = _textEditingController.text;
        _textEditingController.text = '';
      });
    }
  }

  Widget makeGrid() {
    print('newComments ${newComments}');
    print('newComments.length ${newComments.length}');
    return ListView.builder(
      shrinkWrap: true, //just set this property
      padding: EdgeInsets.all(2.0),
      itemCount: newComments.length,
      itemBuilder: (context, index) {
        print(
            "newCommentators[index] ${newCommentators[index]}, newComments[index] ${newComments[index]}");
        if (index != 0) {
          return CommentItem(newCommentators[index], newComments[index]);
        }
        return Divider();
      },
      // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      //   crossAxisCount: 1,
      //   childAspectRatio: 4,
      //   crossAxisSpacing: 1,
      //   mainAxisSpacing: 1,
      // ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // после выхода из этого экрана мы попим новый список комментариев
    var arguments = ModalRoute.of(context).settings.arguments as Set<Object>;
    newComments = arguments.elementAt(0) as List<dynamic>;
    print("NEW_COMMENTS ${newComments}");
    newCommentators = arguments.elementAt(1) as List<dynamic>;
    curEvent = arguments.elementAt(2) as Drug;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Комментарии', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 530,
              child: makeGrid(),
            ),
            // тут отобразить сетку комментариев
            SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).primaryColor,
                ),
                width: 550,
                // height: MediaQuery.of(context).size.height * 0.2,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(39.0),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                        decoration: InputDecoration(
                          labelText: "Введите свой комментарий",
                          labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                        textInputAction: TextInputAction.next,
                        controller: _textEditingController,
                        onFieldSubmitted: (value) {
                          newComment = value;
                          print('Subm newComment ${newComment}');
                        },
                        validator: ((value) =>
                            value.isEmpty ? 'Please provide a name' : null),
                      ),
                    ),
                    TextButton(
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(25)),
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(20)))),
                      child: Text(
                        "Добавить комментарий",
                        style: TextStyle(
                          fontSize: 22,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      onPressed: () =>
                          setNewComments(_textEditingController.text),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
