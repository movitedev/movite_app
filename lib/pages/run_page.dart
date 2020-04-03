import 'package:flutter/material.dart';

class RunPage extends StatefulWidget {
  static String tag = 'profile-page';

  @override
  _RunPageState createState() => new _RunPageState();
}

class _RunPageState extends State<RunPage> {
  @override
  Widget build(BuildContext context) {
    final text = Text(
      'Run,',
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
