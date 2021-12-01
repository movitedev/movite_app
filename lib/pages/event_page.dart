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
      'Work in progress',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black54,
        fontSize: 24.0,
      ),
    );

    return new Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 48.0,
              child: Image.asset('assets/wip.png'),
            ),
            text,
          ],
        ),
      ),
    );
  }
}
