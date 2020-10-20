import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = Text(
      'Movite',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.blue,
        fontSize: 28.0,
      ),
    );
    final text = Text(
      'The social mobility app',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black54,
        fontSize: 20.0,
      ),
    );
    final version = Text(
      'v0.1',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black38,
        fontSize: 14.0,
      ),
    );

    return new Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            title,
            text,
            SizedBox(height: 10,),
            version,
          ],
        ),
      ),
    );
  }
}