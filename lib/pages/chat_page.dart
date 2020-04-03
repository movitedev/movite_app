import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  static String tag = 'profile-page';

  @override
  _ChatPageState createState() => new _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    final text = Text(
      'Chat,',
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
