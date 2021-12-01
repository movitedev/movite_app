import 'dart:convert';

import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:movite_app/commons/env.dart';
import 'package:movite_app/commons/preferences.dart';
import 'package:movite_app/models/User.dart';
import 'package:movite_app/models/UserAndToken.dart';
import 'package:movite_app/pages/home_page.dart';
import 'package:movite_app/pages/signup_page.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var _googleSignIn = GoogleSignIn();

  void showBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: new Text(value),
      behavior: SnackBarBehavior.floating,
      elevation: 8,
    ));
  }

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<User> attemptLogIn(String email, String password) async {
    var res = await http.post(Uri.parse("${environment['url']}/users/login"),
        body: {"email": email, "password": password});
    if (res.statusCode == 200) {
      UserAndToken userAndToken = UserAndToken.fromJson(json.decode(res.body));
      await MyPreferences.setAuthCode(userAndToken.token);
      await MyPreferences.saveUser(userAndToken.user);
      return userAndToken.user;
    } else if (res.statusCode == 401) {
      final snackBar = SnackBar(
        content: Text("Check your email to verify the account."),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        action: SnackBarAction(
          label: "Resend email",
          onPressed: () async {
            await http.post(Uri.parse("${environment['url']}/users/email"),
                body: {"email": email});
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar((snackBar));
      return null;
    } else if (res.statusCode == 409) {
      showBar("Account was found, but needs social login");
      return null;
    } else {
      showBar("No account was found matching that email and password");
      return null;
    }
  }

  Future<User> attemptGoogleLogin(String token) async {
    var res = await http
        .post(Uri.parse("${environment['url']}/users/google"), body: {"token": token});
    if (res.statusCode == 200) {
      UserAndToken userAndToken = UserAndToken.fromJson(json.decode(res.body));
      await MyPreferences.setAuthCode(userAndToken.token);
      await MyPreferences.saveUser(userAndToken.user);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
      return userAndToken.user;
    } else {
      showBar("There was an error");
      return null;
    }
  }

  int _state = 0;

  Widget setButtonChild() {
    if (_state == 0) {
      return Text('Log In', style: TextStyle(color: Colors.white));
    } else {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    }
  }

  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;

    if (args != null) {
      if (args.containsKey('showBar')) {
        if (args['showBar']) {
          args['showBar'] = false;
          WidgetsBinding.instance.addPostFrameCallback(
              (_) => showBar("Check your email to verify the account."));
        }
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Center(
        child: Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 40.0, right: 40.0, top: 20.0),
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 48.0,
                    child: Image.asset('assets/logo.png'),
                  ),
                  SizedBox(height: 48.0),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: false,
                    decoration: InputDecoration(
                      icon: Icon(Icons.mail),
                      labelText: 'E-Mail',
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.0),
                  TextFormField(
                    controller: passwordController,
                    autofocus: false,
                    obscureText: true,
                    decoration: InputDecoration(
                      icon: Icon(Icons.lock),
                      labelText: 'Password',
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24.0),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            if (_state == 0) {
                              setState(() {
                                _state = 1;
                              });
                            }
                          });

                          String email = emailController.text;
                          String password = passwordController.text;
                          User user = await attemptLogIn(email, password);

                          setState(() {
                            _state = 0;
                          });

                          if (user != null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()),
                            );
                          }
                        }
                      },
                      child: setButtonChild(),
                    ),
                  ),
                  TextButton(
                    child: Text(
                      'Create New Account',
                      style: TextStyle(
                          color: Colors.black87,
                          decoration: TextDecoration.underline),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                  ),
                  SizedBox(height: 48.0),
                  Align(
                    alignment: Alignment.center,
                    child: GoogleAuthButton(
                      onPressed: () async {
                        final GoogleSignInAccount googleUser =
                            await _googleSignIn.signIn();
                        final googleKey = await googleUser.authentication;

                        setState(() {
                          if (_state == 0) {
                            setState(() {
                              _state = 1;
                            });
                          }
                        });

                        User user = await attemptGoogleLogin(googleKey.idToken);

                        setState(() {
                          _state = 0;
                        });

                        if (user != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        }
                      },
                      darkMode: true, // default: false
                    ),
                  ),
                  SizedBox(height: 8.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
