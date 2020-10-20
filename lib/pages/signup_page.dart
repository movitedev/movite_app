import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movite_app/commons/env.dart';
import 'package:movite_app/commons/global_variables.dart' as global;
import 'package:movite_app/components/place_autocomplete.dart';

import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  static String tag = 'signup-page';

  @override
  _SignUpPageState createState() => new _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final conpasController = TextEditingController();
  final homeController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    ageController.dispose();
    conpasController.dispose();
    homeController.dispose();

    super.dispose();
  }

  bool passwordCheck() {
    return (passwordController.text == conpasController.text) &&
        (passwordController.text.length >= 6);
  }

  void showBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
      behavior: SnackBarBehavior.floating,
      elevation: 8,
    ));
  }

  Future<bool> attemptSignUp(
      String email, String password, String name, String age) async {
    var res = await http.post("${environment['url']}/users",
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": email,
          "password": password,
          "name": name,
          "age": age,
          "home": global.fromPlace.toJson()
        }));
    if (res.statusCode == 201) {
      return true;
    } else if (res.statusCode == 409) {
      showBar("Error, email is already taken.");
      return false;
    } else {
      showBar("Error, could not create user.");
      return false;
    }
  }

  int _state = 0;

  Widget setButtonChild() {
    if (_state == 0) {
      return Text('Sign Up', style: TextStyle(color: Colors.white));
    } else {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = TextFormField(
      controller: nameController,
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(
        icon: Icon(Icons.person),
        labelText: 'Full Name',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );

    final email = TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: InputDecoration(
        icon: Icon(Icons.mail),
        labelText: 'E-Mail',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );

    final age = TextFormField(
      controller: ageController,
      keyboardType: TextInputType.number,
      autofocus: false,
      decoration: InputDecoration(
        icon: Icon(Icons.face),
        labelText: 'Age',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      ),
    );

    final password = TextFormField(
      controller: passwordController,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        icon: Icon(Icons.lock),
        labelText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );

    final conpass = TextFormField(
      controller: conpasController,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        icon: Icon(Icons.spellcheck),
        labelText: 'Confirm Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );

    final home = PlaceAutocomplete("Home", homeController, true);

    final loginButton = Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onPressed: () async {
            String email = emailController.text;
            String password = passwordController.text;
            String name = nameController.text;
            String age = ageController.text;

            if (_formKey.currentState.validate()) {
              if (passwordCheck()) {
                setState(() {
                  if (_state == 0) {
                    setState(() {
                      _state = 1;
                    });
                  }
                });
                bool success = await attemptSignUp(email, password, name, age);
                setState(() {
                  _state = 0;
                });
                if (success) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                      settings: RouteSettings(
                        arguments: {'showBar': true},
                      ),
                    ),
                  );
                  //Navigator.pushReplacementNamed(context, '/login',
                  //arguments: {'showBar': true});
                }
              } else {
                showBar(
                    "Passwords must match and be at least 6 charachers long.");
              }
            }
          },
          padding: EdgeInsets.all(12),
          color: Colors.lightBlueAccent,
          child: setButtonChild(),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Center(
        child: Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Container(
                child: ListView(
                  padding: EdgeInsets.only(left: 40.0, right: 40.0, top: 20.0),
                  children: <Widget>[
                    name,
                    SizedBox(height: 12.0),
                    email,
                    SizedBox(height: 12.0),
                    age,
                    SizedBox(height: 12.0),
                    home,
                    SizedBox(height: 12.0),
                    password,
                    SizedBox(height: 12.0),
                    conpass,
                    SizedBox(height: 24.0),
                    loginButton,
                    SizedBox(height: 8.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
