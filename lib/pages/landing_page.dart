import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movite_app/commons/env.dart';
import 'package:movite_app/commons/preferences.dart';
import 'package:movite_app/models/User.dart';
import 'package:movite_app/pages/home_page.dart';
import 'package:movite_app/pages/login_page.dart';

class LandingPage extends StatelessWidget {
  Future<bool> checkIfAuthenticated() async {
    var jwt = (await MyPreferences.getAuthCode())!;
    var res = await http.get(Uri.parse("${environment['url']}/users/me"), headers: {
      'Authorization': jwt,
    });
    if (res.statusCode == 200) {
      User user = User.fromJson(json.decode(res.body));

      await MyPreferences.saveUser(user);

      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    checkIfAuthenticated().then((success) {
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        //Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        //Navigator.pushReplacementNamed(context, '/login');
      }
    });

    return Scaffold(
        body: Center(
      child: CircularProgressIndicator(),
    ));
  }
}
