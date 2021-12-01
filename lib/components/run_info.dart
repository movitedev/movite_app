import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movite_app/models/Place.dart';

class RunInfo extends StatelessWidget {
  const RunInfo({
    Key key,
    this.from,
    this.to,
    this.eventDate,
    this.driverName,
    this.createdAtDate,
  }) : super(key: key);

  final Place from;
  final Place to;
  final DateTime eventDate;
  final String driverName;
  final DateTime createdAtDate;

  Widget childElement(String title, String value, IconData icon, double width) {
    List<Widget> children = [];

    children.addAll([
      Icon(
        icon,
        color: Colors.blue[500],
      ),
      SizedBox(
        width: 10,
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(5.0),
            width: width,
            child: new Column(children: <Widget>[
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ]),
          ),
        ],
      )
    ]);

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget fromTo(Place from, Place to, width) {
    Widget fromChild =
        childElement("From", from.name, Icons.location_on, width);
    Widget toChild = childElement("To", to.name, Icons.location_on, width);

    return Column(
      children: <Widget>[
        fromChild,
        toChild,
      ],
    );
  }

  Widget runDate(DateTime dateTime, width) {
    return childElement(
        "Event Date",
        DateFormat('dd-MM-yyyy – kk:mm').format(dateTime.toLocal()),
        Icons.calendar_today,
        width);
  }

  Widget driver(String driver, width) {
    return childElement("Driver", driver, Icons.directions_car, width);
  }

  Widget createdAt(DateTime dateTime, width) {
    return childElement(
        "Created at",
        DateFormat('dd-MM-yyyy – kk:mm').format(dateTime.toLocal()),
        Icons.event_available,
        width);
  }

  Widget createList(double width) {
    List<Widget> widgetList = [];

    if (from != null && to != null) {
      widgetList.add(fromTo(from, to, width));
    }
    if (eventDate != null) {
      widgetList.add(runDate(eventDate, width));
    }
    if (driverName != null) {
      widgetList.add(driver(driverName, width));
    }
    if (createdAtDate != null) {
      widgetList.add(createdAt(createdAtDate, width));
    }

    return Column(children: widgetList);
  }

  @override
  Widget build(BuildContext context) {
    return createList(MediaQuery.of(context).size.width * 0.75);
  }
}
