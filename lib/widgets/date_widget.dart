import 'package:flutter/material.dart';

import '../providers/drug.dart';

class DateWidget extends StatefulWidget {
  Drug curEvent;
  Map<String, dynamic> redactedEvent;
  DateWidget(this.curEvent, this.redactedEvent);

  @override
  State<DateWidget> createState() => _DateWidgetState();
}

class _DateWidgetState extends State<DateWidget> {
  Future<DateTime> _selectDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      helpText: "",
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
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
      setState(() {
        selectedDate = selected;
      });
    }
    return selectedDate;
  }

  // Future<TimeOfDay> _selectTime(BuildContext context) async {
  //   TimeOfDay selectedTime = TimeOfDay.now();
  //   final selected = await showTimePicker(
  //     context: context,
  //     helpText: "",
  //     initialTime: selectedTime,
  //     builder: (context, child) {
  //       return Theme(
  //         data: Theme.of(context).copyWith(
  //           timePickerTheme: TimePickerThemeData(
  //             backgroundColor: Theme.of(context).colorScheme.secondary,
  //           ),
  //           colorScheme: ColorScheme.light(
  //             primary: Theme.of(context).primaryColor,
  //             onPrimary: Theme.of(context).colorScheme.secondary,
  //             onSurface: Theme.of(context).primaryColor,
  //           ),
  //           textButtonTheme: TextButtonThemeData(
  //             style: TextButton.styleFrom(
  //               primary: Theme.of(context).primaryColor,
  //             ),
  //           ),
  //         ),
  //         child: child,
  //       );
  //     },
  //   );
  //   if (selected != null && selected != selectedTime) {
  //     setState(() {
  //       selectedTime = selected;
  //     });
  //   }
  //   return selectedTime;
  // }

  Future<String> _selectDateTime(BuildContext context) async {
    DateTime dateTime = null;
    final date = await _selectDate(context);
    if (date == null) return null;

    // final time = await _selectTime(context);
    // if (time == null) return null;

    setState(() {
      dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        // time.hour,
        // time.minute,
      );
      String newTime =
          dateTime.toString().substring(0, dateTime.toString().length - 13);
      ;
      widget.redactedEvent['dateTime'] = newTime;
      widget.curEvent.dateTime = newTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: TextButton(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.curEvent.dateTime == '' || widget.curEvent.dateTime == null
                ? 'Дата не выбрана'
                : widget.curEvent.dateTime,
            style:
                TextStyle(fontSize: 15, color: Theme.of(context).primaryColor),
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          padding: EdgeInsets.only(right: 170),
        ),
        onPressed: () => _selectDateTime(context),
      ),
    );
  }
}
