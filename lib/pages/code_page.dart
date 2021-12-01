import 'dart:convert';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:movite_app/commons/env.dart';
import 'package:movite_app/commons/preferences.dart';
import 'package:movite_app/models/Run.dart';
import 'package:movite_app/models/User.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CodePage extends StatefulWidget {
  static String tag = 'code-page';

  @override
  _CodePageState createState() => new _CodePageState();
}

class _CodePageState extends State<CodePage> {
  int _state = 0;
  int _buttonState = 0;
  String code;

  void createCode() async {
    var jwt = await MyPreferences.getAuthCode();
    var res = await http.post(Uri.parse("${environment['url']}/users/code"), headers: {
      'Authorization': jwt,
    });
    if (res.statusCode == 200) {
      final responseJson = json.decode(res.body);
      code = responseJson['validRunCode']['code'];
      setState(() {
        _state = 1;
      });
    } else {
      setState(() {
        _state = 2;
      });
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      createCode();
    });

    super.initState();
  }

  Future validateCode(id, code) async {
    String value = "Cannot validate code";

    var jwt = await MyPreferences.getAuthCode();
    var res = await http
        .post(Uri.parse("${environment['url']}/runs/" + id + "/validate"), headers: {
      'Authorization': jwt,
    }, body: {
      "code": code
    });

    if (res.statusCode == 200) {
      User user = User.fromJson(json.decode(res.body)['passenger']);

      value = "Validated user " + user.name;
    } else if (res.statusCode == 409) {
      value = "Code has expired";
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: new Text(value),
      behavior: SnackBarBehavior.floating,
      elevation: 8,
    ));
  }

  Future<String> scanCode() async {
    String code;
    try {
      var barcode = await BarcodeScanner.scan();
      code = barcode.rawContent;
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: new Text("Camera accessis denied"),
          behavior: SnackBarBehavior.floating,
          elevation: 8,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: new Text("Error"),
          behavior: SnackBarBehavior.floating,
          elevation: 8,
        ));
      }
    }

    return code;
  }

  Widget setChild() {
    if (_state == 0) {
      return Container(
          width: 200,
          height: 200,
          child: Center(
            child: CircularProgressIndicator(),
          ));
    } else if (_state == 1) {
      return Container(
          width: 200,
          height: 200,
          child: Center(
            child: QrImage(
              data: code,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ));
    } else {
      return Text("Error");
    }
  }

  Widget setButtonChild() {
    if (_buttonState == 0) {
      return Text('Scansiona QR',
          style: TextStyle(color: Colors.white, fontSize: 20));
    } else {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    }
  }

  Future<List<Widget>> findRuns() async {
    List<Widget> widgets = [];

    var jwt = await MyPreferences.getAuthCode();
    var res =
        await http.get(Uri.parse("${environment['url']}/users/me/runs/given"), headers: {
      'Authorization': jwt,
    });

    if (res.statusCode == 200) {
      List<RunNoPopulate> runs = (json.decode(res.body) as List)
          .map((i) => RunNoPopulate.fromJson(i))
          .toList();

      DateTime now = DateTime.now();

      runs.forEach((run) {
        if ((run.eventDate.difference(now).inMinutes).abs() < 60 * 2) {
          widgets.add(SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context);
                String barcode = await scanCode();
                if (barcode != null) {
                  await validateCode(run.id, barcode);
                }
              },
              child: Column(children: <Widget>[
                Text(run.from.name + " - " + run.to.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    )),
                Text(DateFormat('dd-MM-yyyy – kk:mm').format(run.eventDate.toLocal())),
              ])));
        }
      });
    }

    return widgets;
  }

  Future _asyncSimpleDialog(BuildContext context) async {
    List<Widget> runs = await findRuns();

    setState(() {
      _buttonState = 0;
    });

    if (runs.length > 0) {
      return await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return SimpleDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: const Text('Select a Run to validate'),
                children: runs);
          });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: new Text("You have no runs to validate"),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Align(
                alignment: Alignment.center,
                child: ListView(shrinkWrap: true, children: <Widget>[
                  SizedBox(height: 12.0),
                  Text('Sei il passeggero?',
                      style: TextStyle(color: Colors.black, fontSize: 28.0),
                      textAlign: TextAlign.center),
                  SizedBox(height: 6.0),
                  Text(
                    "Fai scansionare il QR Code per validare la corsa",
                    style: TextStyle(color: Colors.black45, fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.0),
                  setChild(),
                  SizedBox(height: 24.0),
                  Text("Sei l'autista?",
                      style: TextStyle(color: Colors.black, fontSize: 28.0),
                      textAlign: TextAlign.center),
                  SizedBox(height: 6.0),
                  Text("Scansiona il QR Code dei passeggeri",
                      style: TextStyle(color: Colors.black45, fontSize: 20.0),
                      textAlign: TextAlign.center),
                  SizedBox(height: 8.0),
                  Align(
                      child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              _buttonState = 1;
                            });
                            await _asyncSimpleDialog(context);
                          },
                          child: setButtonChild())),
                  SizedBox(height: 8.0),
                ]))));
  }
}
