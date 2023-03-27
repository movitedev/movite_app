import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:movite_app/commons/env.dart';
import 'package:movite_app/commons/global_variables.dart' as global;
import 'package:movite_app/commons/preferences.dart';
import 'package:movite_app/components/run_info.dart';
import 'package:movite_app/models/Chat.dart';
import 'package:movite_app/models/Place.dart';
import 'package:movite_app/models/Run.dart';
import 'package:movite_app/pages/offer_page.dart';

import 'home_page.dart';

double _spaceOffset = 5;
double _timeOffset = 60;

class SearchPage extends StatefulWidget {
  static String tag = 'profile-page';

  @override
  _SearchPageState createState() => new _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  String name = "";
  String email = "";
  String role = "";
  String age = "";
  String createdAt = "";

  String? myId = "";

  int driverNumber = 0;
  int passengerNumber = 0;

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

  ListView runsList(data) {
    data.sort((Run a, Run b) => a.eventDate!.compareTo(b.eventDate!));

    return ListView.builder(
        itemCount: data.length,
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemBuilder: (context, index) {
          return tile(
              data[index].from.name + " - " + data[index].to.name,
              DateFormat('dd-MM-yyyy – kk:mm')
                  .format(data[index].eventDate.toLocal()),
              data[index],
              context);
        });
  }

  ListTile tile(String title, String subtitle, Run? run, BuildContext context) =>
      ListTile(
        title: Text(title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
            )),
        subtitle: Text(subtitle),
        leading: Icon(
          Icons.directions_car,
          color: Colors.blue[500],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OfferDetailsPage(run, myId),
            ),
          );
        },
      );

  Future<List<Run>> getRuns() async {
    var jwt = (await MyPreferences.getAuthCode())!;

    myId = await MyPreferences.getId();

    var res = await http.post(Uri.parse("${environment['url']}/runs/search"),
        headers: {'Authorization': jwt, "Content-Type": "application/json"},
        body: json.encode({
          'from': global.fromPlace!.toJson(),
          'to': global.toPlace!.toJson(),
          'eventDate': global.dateTime!.toUtc().toIso8601String(),
          'spaceOffset': _spaceOffset,
          'timeOffset': _timeOffset
        }));

    if (res.statusCode == 200) {
      List<Run> runs =
          (json.decode(res.body) as List).map((i) => Run.fromJson(i)).toList();

      return runs;
    } else {
      throw Exception('Failed to load jobs from API');
    }
  }

  Widget bar() {
    Row row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text("Select a run",
            style: TextStyle(color: Colors.black, fontSize: 20.0)),
        Text("OR", style: TextStyle(color: Colors.black45, fontSize: 16.0)),
        ElevatedButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OfferPage(),
                ),
              );
            },
            child: Text('Use your car', style: TextStyle(color: Colors.white)))
      ],
    );

    return row;
  }

  Future<void> customSimpleDialog(BuildContext context) async {
    var dialog = MyDialogContent();
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Search"),
        backgroundColor: Colors.lightBlueAccent,
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () async {
              await customSimpleDialog(context);
              setState(() {});
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(30),
          children: <Widget>[
            RunInfo(from: global.fromPlace, to: global.toPlace, eventDate: global.dateTime),
            bar(),
            SizedBox(
              height: 15.0,
            ),
            FutureBuilder<List<Run>>(
              future: getRuns(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Run> data = snapshot.data!;
                  if (data.length > 0) {
                    return runsList(data);
                  } else {
                    return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text("No runs found")]);
                  }
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MyDialogContent extends StatefulWidget {
  @override
  _MyDialogContentState createState() => new _MyDialogContentState();
}

class _MyDialogContentState extends State<MyDialogContent> {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Row(
        children: <Widget>[
          Icon(Icons.filter_list),
          SizedBox(
            width: 15,
          ),
          Text(
            "Filtra la ricerca",
          )
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      //backgroundColor: Colors.amber,
      elevation: 10,
      children: [
        SizedBox(
          height: 20,
        ),
        Text(
          "Distanza max",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                "1 km",
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              flex: 6,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.blue[500],
                  inactiveTrackColor: Colors.blue[100],
                  trackShape: RoundedRectSliderTrackShape(),
                  trackHeight: 4.0,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                  thumbColor: Colors.blueAccent,
                  overlayColor: Colors.blue.withAlpha(32),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                  tickMarkShape: RoundSliderTickMarkShape(),
                  activeTickMarkColor: Colors.blue[500],
                  inactiveTickMarkColor: Colors.blue[100],
                  valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                  valueIndicatorColor: Colors.blueAccent,
                  valueIndicatorTextStyle: TextStyle(
                    color: Colors.white,
                  ),
                ),
                child: Slider(
                  value: _spaceOffset,
                  min: 1,
                  max: 20,
                  divisions: 19,
                  label: '$_spaceOffset',
                  onChanged: (value) {
                    setState(() {
                      _spaceOffset = value;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                "20 km",
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 25,
        ),
        Text(
          "Offset tempo max",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                "10 min",
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              flex: 6,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.blue[500],
                  inactiveTrackColor: Colors.blue[100],
                  trackShape: RoundedRectSliderTrackShape(),
                  trackHeight: 4.0,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                  thumbColor: Colors.blueAccent,
                  overlayColor: Colors.blue.withAlpha(32),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                  tickMarkShape: RoundSliderTickMarkShape(),
                  activeTickMarkColor: Colors.blue[500],
                  inactiveTickMarkColor: Colors.blue[100],
                  valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                  valueIndicatorColor: Colors.blueAccent,
                  valueIndicatorTextStyle: TextStyle(
                    color: Colors.white,
                  ),
                ),
                child: Slider(
                  value: _timeOffset,
                  min: 10,
                  max: 200,
                  divisions: 19,
                  label: '$_timeOffset',
                  onChanged: (value) {
                    setState(() {
                      _timeOffset = value;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                "200 min",
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class OfferDetailsPage extends StatefulWidget {
  static String tag = 'details-page';

  final Run? run;
  final String? myId;

  const OfferDetailsPage(this.run, this.myId);

  @override
  _OfferDetailsPageState createState() => new _OfferDetailsPageState();
}

class _OfferDetailsPageState extends State<OfferDetailsPage> {

  bool? currentStatus;

  Widget childElement(String title, String value, IconData icon) {
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
      height: 65,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget fromTo(Place from, Place to) {
    Widget fromChild = childElement("From", from.name!, Icons.location_on);
    Widget toChild = childElement("To", to.name!, Icons.location_on);

    return Column(
      children: <Widget>[
        fromChild,
        toChild,
      ],
    );
  }

  Widget eventDate(DateTime dateTime) {
    return childElement(
        "Event Date",
        DateFormat('dd-MM-yyyy – kk:mm').format(dateTime.toLocal()),
        Icons.calendar_today);
  }



  Widget sectionTitle(String title) {
    return Column(children: <Widget>[
      Text(
        title,
        style: TextStyle(
          fontSize: 18,
          color: Colors.black54,
        ),
      ),
      SizedBox(
        height: 20,
      ),
    ]);
  }

  void showBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: new Text(value),
      behavior: SnackBarBehavior.floating,
      elevation: 8,
    ));
  }

  Future<void> requestRun() async {
    setState(() {
      _state = 1;
    });

    var jwt = (await MyPreferences.getAuthCode())!;
    // create chat if not exists

    var res = await http.get(Uri.parse("${environment['url']}/chats"), headers: {
      'Authorization': jwt,
    });

    Chat? chat;

    if (res.statusCode == 200) {
      List<Chat> chats =
          (json.decode(res.body) as List).map((i) => Chat.fromJson(i)).toList();

      chats.forEach((element) {
        element.partecipants.forEach((part) {
          if (part.partecipant.id == widget.run!.driver!.id) {
            chat = element;
          }
        });
      });

      if (chat == null) {
        var result = await http.post(Uri.parse("${environment['url']}/chats"),
            headers: {'Authorization': jwt, "Content-Type": "application/json"},
            body: json.encode({
              "partecipants": [
                {"partecipant": widget.run!.driver!.id},
                {"partecipant": widget.myId}
              ]
            }));
        if (result.statusCode == 201) {
          chat = Chat.fromJson(json.decode(result.body));
        } else {
          showBar("Error");
          return;
        }
      }
    }

    //send message

    if (chat != null) {
      var r = await http.post(
          Uri.parse("${environment['url']}/chats/" + chat!.id! + "/messages"),
          headers: {
            'Authorization': jwt,
          },
          body: {
            "message": "Chiedo un passaggio per la corsa da " +
                widget.run!.from!.name! +
                " a " +
                widget.run!.to!.name! +
                ", in data " +
                DateFormat('dd-MM-yyyy – kk:mm').format(widget.run!.eventDate!),
            "activeRequest": 'true',
            "run": widget.run!.id
          });

      if (r.statusCode == 201) {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
            settings: RouteSettings(
              arguments: {'showBar4': true},
            ),
          ),
        );
      } else {
        showBar("Unable to send the message");
      }
    }

    setState(() {
      _state = 0;
    });
  }

  int _state = 0;

  Widget setButtonChild() {
    if (_state == 0) {
      return Text('Request run', style: TextStyle(color: Colors.white));
    } else {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(30.0),
          children: <Widget>[
            sectionTitle("Run information:"),
            RunInfo(from: widget.run!.from, to: widget.run!.to, eventDate: widget.run!.eventDate, driverName: widget.run!.driver!.name, createdAtDate: widget.run!.createdAt,),
            SizedBox(
              height: 15,
            ),
            Align(
                child: widget.myId != widget.run!.driver!.id
                    ? ElevatedButton(
                        onPressed: () async {
                          requestRun();
                        },
                        child: setButtonChild())
                    : Text("You are the driver of this run.")),
          ],
        ),
      ),
    );
  }
}
