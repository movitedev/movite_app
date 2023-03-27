import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movite_app/commons/global_variables.dart' as global;

class DatetimeSelector extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  DatetimeSelector(this.title, this.controller);

  @override
  _DatetimeSelectorState createState() => _DatetimeSelectorState();
}

class _DatetimeSelectorState extends State<DatetimeSelector> {

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  Future _selectDateTime(BuildContext context) async {
    final DateTime? datePicked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (datePicked == null) {
      return;
    }

    final TimeOfDay? timePicked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (timePicked == null) {
      return;
    }

    setState(() {
      global.dateTime = DateTime(
          datePicked.year,
          datePicked.month,
          datePicked.day,
          timePicked.hour,
          timePicked.minute)
          .toLocal();
      widget.controller.text =
          DateFormat('dd-MM-yyyy – kk:mm').format(global.dateTime!);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Column(children: <Widget>[
      TextFormField(
        controller: widget.controller,
        readOnly: true,
        autofocus: false,
        decoration: InputDecoration(
          icon: Icon(Icons.calendar_today),
          labelText: widget.title,
          contentPadding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
        ),
        onTap: () async {
          await _selectDateTime(context);
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter a time';
          }
          return null;
        },
      ),
      Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: TextButton(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.timer, color: Colors.black87),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Fra poco',
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                  ]),
              onPressed: () {
                global.dateTime = (DateTime.now()).add(Duration(minutes: 5)).toLocal();
                widget.controller.text = DateFormat('dd-MM-yyyy – kk:mm')
                    .format(global.dateTime!);
              },
            ),
          ),
          Expanded(
            flex: 5,
            child: TextButton(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.timer, color: Colors.black87),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Fra 2 ore',
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                  ]),
              onPressed: () {
                global.dateTime = (DateTime.now()).add(Duration(hours: 2)).toLocal();
                widget.controller.text = DateFormat('dd-MM-yyyy – kk:mm')
                    .format(global.dateTime!);
              },
            ),
          ),
        ],
      ),
    ]);
  }
}