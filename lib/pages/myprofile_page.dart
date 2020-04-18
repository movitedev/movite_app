import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:movite_app/commons/env.dart';
import 'package:movite_app/commons/preferences.dart';
import 'package:movite_app/models/User.dart';

class MyProfilePage extends StatefulWidget {
  static String tag = 'profile-page';

  @override
  _MyProfilePageState createState() => new _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  int _dataState = 0;

  String name = "";
  String email = "";
  String role = "";
  String age = "";
  String createdAt = "";

  int driverNumber = 0;
  int passengerNumber = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      User me = await MyPreferences.getUser();

      name = me.name;
      email = me.email;
      role = me.role;
      age = me.age.toString();
      createdAt = DateFormat('dd-MM-yyyy').format(me.createdAt);

      setState(() {});

      getStats();
    });

    super.initState();
  }

  Widget statField(IconData icon, String title, int number) {
    return Column(
      children: <Widget>[
        Icon(
          icon,
          color: Colors.blue[500],
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
        Text(
          number.toString(),
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget runsTab() {
    List<Widget> children = List<Widget>();

    Widget driver =
        statField(Icons.directions_car, "Driver Runs", driverNumber);
    Widget passenger = statField(
        Icons.airline_seat_recline_normal, "Passenger Runs", passengerNumber);

    if (_dataState != 0) {
      children.addAll([
        Expanded(flex: 5, child: driver),
        Expanded(flex: 5, child: passenger)
      ]);
    } else {
      children.add(CircularProgressIndicator());
    }

    return Container(
        height: 80,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          ],
        ));
  }

  Future getStats() async {
    var jwt = await MyPreferences.getAuthCode();
    var myId = await MyPreferences.getId();

    var res = await http
        .get("${environment['url']}/users/" + myId + "/stats", headers: {
      'Authorization': jwt,
    });

    if (res.statusCode == 200) {
      Map stats = json.decode(res.body);

      driverNumber = stats['driverNumber'];
      passengerNumber = stats['passengerNumber'];

      setState(() {
        _dataState = 1;
      });
    }
  }

  Widget informationField(String title, String value, IconData icon) {
    List<Widget> children = new List<Widget>();

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
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
            ),
          )
        ],
      )
    ]);

    return Container(
      width: 120,
      height: 65,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget informationTab() {
    Widget ageField = informationField("Age", age, Icons.face);
    Widget roleField = informationField("Role", role, Icons.verified_user);
    Widget sinceField =
        informationField("Since", createdAt, Icons.calendar_today);
    Widget placeField = informationField("Place", "Cles", Icons.place);

    return Row(
      children: <Widget>[
        Expanded(
            flex: 5,
            child: Column(children: <Widget>[
              ageField,
              roleField,
            ])),
        Expanded(
            flex: 5,
            child: Column(children: <Widget>[
              placeField,
              sinceField,
            ])),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Text(
      'Welcome to Movite',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black54,
        fontSize: 16.0,
      ),
    );

    final profileText = Text(
      'User information',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black54,
        fontSize: 16.0,
      ),
    );

    final nameText = Text(
      name,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black,
        fontSize: 20.0,
      ),
    );

    final emailText = Text(
      email,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black,
        fontSize: 16.0,
      ),
    );

    final addFlat = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onPressed: () {
          //Navigator.of(context).pushNamed('');
        },
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Modifica profilo', style: TextStyle(color: Colors.white)),
      ),
    );

    return new Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
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
            SizedBox(height: 15.0),
            nameText,
            SizedBox(height: 10.0),
            runsTab(),
            SizedBox(height: 30.0),
            profileText,
            SizedBox(
              height: 30,
            ),
            informationTab(),
            SizedBox(height: 30.0),
            text,
            SizedBox(height: 10.0),
            emailText,
            Column(children: <Widget>[
              addFlat,
            ]),
          ],
        ),
      ),
    );
  }
}
