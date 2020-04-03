import 'package:flutter/material.dart';

class EventPage extends StatefulWidget {
  static String tag = 'profile-page';

  @override
  _EventPageState createState() => new _EventPageState();
}

class _EventPageState extends State<EventPage> {
  @override
  Widget build(BuildContext context) {
    final text = Text(
      'Event,',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black54,
        fontSize: 13.0,
      ),
    );

    return new Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: text,
      ),
    );
  }
}
