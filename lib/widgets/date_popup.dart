import 'package:flutter/material.dart';

class DateChoose extends StatelessWidget {
  String newTime;

  DateChoose({this.newTime});

  Future<DateTime> _selectDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      helpText: "",
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Theme.of(context).colorScheme.secondary,
              onSurface: Theme.of(context).primaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
            ),
            dialogBackgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          child: child,
        );
      },
    );
    if (selected != null && selected != selectedDate) {
      selectedDate = selected;
      // setState(() {
      //   selectedDate = selected;
      // });
    }
    return selectedDate;
  }

  Future<String> _selectDateTime(BuildContext context) async {
    DateTime dateTime = null;
    final date = await _selectDate(context);
    if (date == null) return null;
    dateTime = DateTime(
      date.year,
      date.month,
      date.day,
    );
    Navigator.of(context).pop(
      dateTime.toString(),
    );

    // setState(() {
    //   dateTime = DateTime(
    //     date.year,
    //     date.month,
    //     date.day,
    //   );
    //   newTime =
    //       dateTime.toString().substring(0, dateTime.toString().length - 4);
    //   ;
    // });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        // градиент на весь экран авторизации
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.9),
                Theme.of(context).colorScheme.secondary.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0, 1],
            ),
          ),
        ),
        SingleChildScrollView(
          child: Container(
            height: deviceSize.height,
            width: deviceSize.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 60,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Image.asset('assets/images/palm-tree.png',
                            fit: BoxFit.fill,
                            height: 40,
                            width: 60,
                            scale: 0.8),
                      ),
                    ],
                  ),
                ),
                AlertDialog(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  title: Text(
                    "Выберите дату",
                    style: TextStyle(
                      fontSize: 22,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(10)),
                        width: double.infinity,
                        child: TextButton(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              // newTime == '' || newTime == null
                              //     ? 'Время не выбрано'
                              //     : newTime,
                              newTime == null ? 'Дата' : newTime,
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            padding: EdgeInsets.only(right: 170),
                          ),
                          onPressed: () => _selectDateTime(context),
                        ),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(newTime);
                          },
                          style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor),
                          child: Text(
                            'Отменить',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 110,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(null);
                          },
                          style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor),
                          child: Text(
                            'Сброс',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                      // actions: <Widget>[
                      //   Row(
                      //     children: [
                      //       TextButton(
                      //         onPressed: () {
                      //           Navigator.of(context).pop();
                      //         },
                      //         style: TextButton.styleFrom(
                      //             foregroundColor: Theme.of(context).primaryColor),
                      //         child: Text(
                      //           'Отменить',
                      //           style: TextStyle(
                      //             fontSize: 18,
                      //             color: Theme.of(context).primaryColor,
                      //           ),
                      //         ),
                      //       ),
                      //       Container(
                      //         padding: EdgeInsets.only(left: 50),
                      //         child: TextButton(
                      //           onPressed: () {
                      //             Navigator.of(context).pop();
                      //           },
                      //           style: TextButton.styleFrom(
                      //               foregroundColor:
                      //                   Theme.of(context).primaryColor),
                      //           child: Text(
                      //             'Применить',
                      //             style: TextStyle(
                      //               fontSize: 18,
                      //               color: Theme.of(context).primaryColor,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
    //  return buildPopupDialog(context);
    // return Placeholder();
  }
}
