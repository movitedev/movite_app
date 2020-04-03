import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  static String tag = 'profile-page';

  @override
  _ProfilePageState createState() => new _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final text = Text(
      'Welcome,',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black54,
        fontSize: 13.0,
      ),
    );

    final name = Text(
      'Harshil Jasoliya',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black,
        fontSize: 20.0,
      ),
    );

    final addflat = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onPressed: () {
          Navigator.of(context).pushNamed('');
        },
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Clap ', style: TextStyle(color: Colors.white)),
      ),
    );
    return new Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 15.0,
            ),
            Container(
              child: Hero(
                tag: 'hero',
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 120.0,
                  child: Image(
                    image: AssetImage('assets/profile.png'),
                  ),
                ),
              ),
            ),
            ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 40.0, right: 40.0),
              children: <Widget>[
                SizedBox(height: 15.0),
                name,
                SizedBox(height: 10.0),
                text,
                SizedBox(height: 10.0),
                addflat,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
