import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:movite_app/commons/env.dart';
import 'package:movite_app/commons/preferences.dart';
import 'package:movite_app/models/User.dart';

class ProfilePage extends StatefulWidget {
  static String tag = 'profile-page';

  final String? id;
  final String? title;

  const ProfilePage(this.id, this.title);

  @override
  _ProfilePageState createState() => new _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _dataState = 0;

  String? name = "";
  String? email = "";
  String? role = "";
  String age = "";
  String? home = "";
  String createdAt = "";

  int? driverNumber = 0;
  int? passengerNumber = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var jwt = (await MyPreferences.getAuthCode())!;

      var res =
          await http.get(Uri.parse("${environment['url']}/users/" + widget.id!), headers: {
        'Authorization': jwt,
      });

      if (res.statusCode == 200) {
        User user = User.fromJson(json.decode(res.body));

        name = user.name;
        email = user.email;
        role = user.role;
        home = user.home.name;
        age = user.age.toString();
        createdAt = DateFormat('dd-MM-yyyy').format(user.createdAt!.toLocal());
      }

      await getStats();
    });

    super.initState();
  }

  Widget statField(IconData icon, String title, int? number) {
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
    List<Widget> children = [];

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
    var jwt = (await MyPreferences.getAuthCode())!;

    var res = await http
        .get(Uri.parse("${environment['url']}/users/" + widget.id! + "/stats"), headers: {
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
    Widget roleField = informationField("Role", role!, Icons.verified_user);
    Widget sinceField =
        informationField("Since", createdAt, Icons.calendar_today);
    Widget placeField = informationField("Place", home!, Icons.place);

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
    final profileText = Text(
      'User information',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black54,
        fontSize: 16.0,
      ),
    );

    final nameText = Text(
      name!,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black,
        fontSize: 20.0,
      ),
    );

    return new Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
        backgroundColor: Colors.lightBlueAccent,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          padding: EdgeInsets.only(left: 30.0, right: 30.0),
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
            SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }
}
