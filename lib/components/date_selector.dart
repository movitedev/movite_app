import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movite_app/commons/global_variables.dart' as global;

class DateSelector extends StatefulWidget {
  final String title;
  final TextEditingController controller;

  DateSelector(this.title, this.controller);

  @override
  _DateSelectorState createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  DateTime date;

  DateTime selectedDate = DateTime(2000);

  Future _selectDateTime(BuildContext context) async {
    final DateTime datePicked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1901),
      lastDate: DateTime.now(),
    );

    if (datePicked == null) {
      return;
    }

    setState(() {
      global.dateTime =
          DateTime(datePicked.year, datePicked.month, datePicked.day).toLocal();
      widget.controller.text = DateFormat('dd-MM-yyyy').format(global.dateTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
        if (value.isEmpty) {
          return 'Please enter a date';
        }
        return null;
      },
    );
  }
}
