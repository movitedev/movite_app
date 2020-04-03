import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:movite_app/commons/env.dart';
import 'package:movite_app/commons/preferences.dart';
import 'package:movite_app/models/Run.dart';

class MovitePage extends StatefulWidget {
  static String tag = 'profile-page';

  @override
  _MovitePageState createState() => new _MovitePageState();
}

class _MovitePageState extends State<MovitePage> {
  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          backgroundColor: Colors.lightBlueAccent,
          flexibleSpace: new Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              new TabBar(
                tabs: [
                  new Tab(
                      child: Row(
                    children: <Widget>[
                      Icon(Icons.directions_car),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Offerti')
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  )),
                  new Tab(
                      child: Row(
                    children: <Widget>[
                      Icon(Icons.airline_seat_recline_normal),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Ricevuti')
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  )),
                ],
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [OfferedPage(), ReceivedPage()],
        ),
      ),
    );
  }
}

ListView runsList(data, IconData icon) {
  data.sort(
      (RunNoPopulate a, RunNoPopulate b) => b.eventDate.compareTo(a.eventDate));

  return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return tile(
            data[index].from.name + " - " + data[index].to.name,
            DateFormat('dd-MM-yyyy – kk:mm').format(data[index].eventDate),
            icon,
            data[index].id,
            context);
      });
}

ListTile tile(String title, String subtitle, IconData icon, String id,
        BuildContext context) =>
    ListTile(
      title: Text(title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
          )),
      subtitle: Text(subtitle),
      leading: Icon(
        icon,
        color: Colors.blue[500],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsPage(),
            settings: RouteSettings(
              arguments: {'id': id},
            ),
          ),
        );
      },
    );

class OfferedPage extends StatefulWidget {
  static String tag = 'offered-page';

  @override
  _OfferedPageState createState() => new _OfferedPageState();
}

class _OfferedPageState extends State<OfferedPage> {
  Future<List<RunNoPopulate>> getRuns() async {
    var jwt = await MyPreferences.getAuthCode();

    var res =
        await http.get("${environment['url']}/users/me/runs/given", headers: {
      'Authorization': jwt,
    });

    if (res.statusCode == 200) {
      List<RunNoPopulate> runs = (json.decode(res.body) as List)
          .map((i) => RunNoPopulate.fromJson(i))
          .toList();

      return runs;
    } else {
      throw Exception('Failed to load jobs from API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RunNoPopulate>>(
      future: getRuns(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<RunNoPopulate> data = snapshot.data;
          return runsList(data, Icons.directions_car);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class ReceivedPage extends StatefulWidget {
  static String tag = 'received-page';

  @override
  _ReceivedPageState createState() => new _ReceivedPageState();
}

class _ReceivedPageState extends State<ReceivedPage> {
  Future<List<RunNoPopulate>> getRuns() async {
    var jwt = await MyPreferences.getAuthCode();

    var res = await http
        .get("${environment['url']}/users/me/runs/received", headers: {
      'Authorization': jwt,
    });

    if (res.statusCode == 200) {
      List<RunNoPopulate> runs = (json.decode(res.body) as List)
          .map((i) => RunNoPopulate.fromJson(i))
          .toList();

      return runs;
    } else {
      throw Exception('Failed to load jobs from API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RunNoPopulate>>(
      future: getRuns(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<RunNoPopulate> data = snapshot.data;
          return runsList(data, Icons.airline_seat_recline_normal);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class DetailsPage extends StatefulWidget {
  static String tag = 'details-page';

  @override
  _DetailsPageState createState() => new _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  Future<RunDetails> getRunDetails(String id) async {
    var jwt = await MyPreferences.getAuthCode();

    var res = await http
        .get("${environment['url']}/runs/" + id + "/details", headers: {
      'Authorization': jwt,
    });

    if (res.statusCode == 200) {
      RunDetails run = RunDetails.fromJson(json.decode(res.body));
      return run;
    } else {
      throw Exception('Failed to load jobs from API');
    }
  }

  @override
  Widget build(BuildContext context) {
    String id = '';

    Map args = ModalRoute.of(context).settings.arguments;

    if (args != null) {
      if (args.containsKey('id')) {
        id = args['id'];
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Details"),
          backgroundColor: Colors.lightBlueAccent,
        ),
        backgroundColor: Colors.white,
        body: FutureBuilder<RunDetails>(
          future: getRunDetails(id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data.toJson().toString());
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ));
  }
}
