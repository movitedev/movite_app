import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:location/location.dart' as gps;
import 'package:movite_app/commons/env.dart';
import 'package:movite_app/commons/preferences.dart';
import 'package:movite_app/components/datetime_selector.dart';
import 'package:movite_app/components/place_selector.dart';
import 'package:movite_app/models/Location.dart' as myLoc;
import 'package:movite_app/models/Place.dart';
import 'package:movite_app/commons/global_variables.dart' as global;

import 'home_page.dart';

const kGoogleApiKey = "AIzaSyBsCUBVW9yHpOi5nFaQ7xuSJ6_1kCXJIx0";

class OfferPage extends StatefulWidget {
  static String tag = 'profile-page';

  @override
  _OfferPageState createState() => new _OfferPageState();
}

class _OfferPageState extends State<OfferPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final fromController = TextEditingController();
  final toController = TextEditingController();
  final dateController = TextEditingController();

  @override
  void initState() {

    fromController.text = global.fromPlace.name;
    toController.text = global.toPlace.name;
    dateController.text = DateFormat('dd-MM-yyyy – kk:mm').format(global.dateTime);

    super.initState();
  }

  void showBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
      behavior: SnackBarBehavior.floating,
      elevation: 8,
    ));
  }

  Future<void> offerRun() async {

    setState(() {
      _state = 1;
    });

    var jwt = await MyPreferences.getAuthCode();

    var res = await http.post("${environment['url']}/runs",
        headers: {'Authorization': jwt, "Content-Type": "application/json"},
        body: json.encode({
          'from': global.fromPlace.toJson(),
          'to': global.toPlace.toJson(),
          'eventDate': global.dateTime.toUtc().toIso8601String()
        }));

    if (res.statusCode == 201) {
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
          settings: RouteSettings(
            arguments: {'showBar3': true},
          ),
        ),
      );
    } else if (res.statusCode == 409) {
      showBar("Error, run date set in the past.");
    } else {
      showBar("Error, could not create run.");
    }

    setState(() {
      _state = 0;
    });

  }

  int _state = 0;

  Widget setButtonChild() {
    if (_state == 0) {
      return Text('Offer run', style: TextStyle(color: Colors.white));
    } else {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Offer"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            children: <Widget>[
              PlaceSelector("Da", fromController, true),
              SizedBox(
                height: 15,
              ),
              SizedBox(
                height: 5,
              ),
              PlaceSelector("A", toController, false),
              SizedBox(
                height: 15,
              ),
              SizedBox(
                height: 5,
              ),
              DatetimeSelector("Quando", dateController),
              SizedBox(
                height: 15,
              ),
              Align(
                  child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          offerRun();
                        }
                      },
                      padding: EdgeInsets.all(20),
                      color: Colors.lightBlueAccent,
                      child: setButtonChild())),
            ],
          ),
        ),
      ),
    );
  }
}
