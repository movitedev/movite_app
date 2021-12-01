import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:movite_app/commons/env.dart';
import 'package:movite_app/commons/preferences.dart';
import 'package:movite_app/components/run_info.dart';
import 'package:movite_app/models/Chat.dart';
import 'package:movite_app/models/Run.dart';
import 'package:movite_app/models/UsersReduced.dart';
import 'package:movite_app/pages/profile_page.dart';

import 'chat_page.dart';
import 'home_page.dart';

class MovitePage extends StatefulWidget {
  static String tag = 'profile-page';

  @override
  _MovitePageState createState() => new _MovitePageState();
}

class _MovitePageState extends State<MovitePage> {

  int _initialIndex = 0;

  void showBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: new Text(value),
      behavior: SnackBarBehavior.floating,
      elevation: 8,
    ));
  }

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;

    if (args != null) {
      if (args.containsKey('showBar1')) {
        if (args['showBar1']) {
          args['showBar1'] = false;
          WidgetsBinding.instance.addPostFrameCallback(
              (_) => showBar("Run Deleted"));
        }
      }

      if (args.containsKey('showBar2')) {
        if (args['showBar2']) {
          args['showBar2'] = false;
          _initialIndex = 1;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showBar("You have left the run");
            _initialIndex = 0;
          });
        }
      }
    }

    return new DefaultTabController(
      length: 2,
      initialIndex: _initialIndex,
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

ListView runsList(data, bool driver) {
  data.sort(
      (RunNoPopulate a, RunNoPopulate b) => b.eventDate.compareTo(a.eventDate));

  return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return tile(
            data[index].from.name + " - " + data[index].to.name,
            DateFormat('dd-MM-yyyy – kk:mm').format(data[index].eventDate.toLocal()),
            data[index].id,
            (DateTime.now()).difference(data[index].eventDate).inMinutes < 60 * 2,
            driver,
            context);
      });
}

ListTile tile(String title, String subtitle, String id, bool active,
        bool driver, BuildContext context) =>
    ListTile(
      title: Text(title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
          )),
      subtitle: Text(subtitle),
      leading: Icon(
        driver ? Icons.directions_car : Icons.airline_seat_recline_normal,
        color: active ? Colors.blue[500] : null,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsPage(id, active, driver),
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
        await http.get(Uri.parse("${environment['url']}/users/me/runs/given"), headers: {
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
          return runsList(data, true);
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
        .get(Uri.parse("${environment['url']}/users/me/runs/received"), headers: {
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
          return runsList(data, false);
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

  final String id;
  final bool active;
  final bool driver;

  const DetailsPage(this.id, this.active, this.driver);

  @override
  _DetailsPageState createState() => new _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {

  bool currentStatus;

  RunDetails run;

  String myId = "";

  Future<RunDetails> getRunDetails(String id) async {
    myId = await MyPreferences.getId();

    var jwt = await MyPreferences.getAuthCode();

    var res = await http
        .get(Uri.parse("${environment['url']}/runs/" + id + "/details"), headers: {
      'Authorization': jwt,
    });

    if (res.statusCode == 200) {
      RunDetails run = RunDetails.fromJson(json.decode(res.body));
      return run;
    } else {
      throw Exception('Failed to load jobs from API');
    }
  }

  Widget menuChild(IconData iconData, String title) {
    return Row(children: <Widget>[
      Icon(
        iconData,
        color: Colors.blue[500],
      ),
      SizedBox(
        width: 10,
      ),
      Text(title)
    ]);
  }

  Widget passengersWidget(
      Passenger passenger, bool validated, bool driverWidget) {
    List<Widget> children = [];

    Widget button = Container();

    if (driverWidget) {
      if (!widget.driver) {
        //passenger's driverWidget
        button = PopupMenuButton(
          onSelected: (value) async {
            await passengersHandler(value, passenger);
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                value: 0,
                child: menuChild(Icons.account_circle, "Profile"),
              ),
              PopupMenuItem(
                value: 1,
                child: menuChild(Icons.message, "Chat"),
              ),
            ];
          },
        );
      } else {
        //driver's driverWidget
        button = Container(
          padding: EdgeInsets.all(10),
          child: Text(
            "(You)",
            style: TextStyle(fontSize: 16),
          ),
        );
      }
    } else {
      if (widget.driver) {
        //driver's passengerWidget

        if (widget.active) {
          if (validated) {
            button = PopupMenuButton(
              onSelected: (value) async {
                await passengersHandler(value, passenger);
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    value: 0,
                    child: menuChild(Icons.account_circle, "Profile"),
                  ),
                  PopupMenuItem(
                      value: 1, child: menuChild(Icons.message, "Chat")),
                ];
              },
            );
          } else {
            button = PopupMenuButton(
              onSelected: (value) async {
                await passengersHandler(value, passenger);
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    value: 0,
                    child: menuChild(Icons.account_circle, "Profile"),
                  ),
                  PopupMenuItem(
                      value: 1, child: menuChild(Icons.message, "Chat")),
                  PopupMenuItem(
                    value: 2,
                    child: menuChild(Icons.clear, "Remove"),
                  ),
                ];
              },
            );
          }
        } else {
          button = PopupMenuButton(
            onSelected: (value) async {
              await passengersHandler(value, passenger);
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 0,
                  child: menuChild(Icons.account_circle, "Profile"),
                ),
                PopupMenuItem(
                    value: 1, child: menuChild(Icons.message, "Chat")),
              ];
            },
          );
        }
      } else {
        //passenger's passengerWidget
        if (passenger.id == myId) {
          button = Container(
            padding: EdgeInsets.all(10),
            child: Text(
              "(You)",
              style: TextStyle(fontSize: 16),
            ),
          );
        } else {
          button = PopupMenuButton(
            onSelected: (value) async {
              await passengersHandler(value, passenger);
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 0,
                  child: menuChild(Icons.account_circle, "Profile"),
                ),
              ];
            },
          );
        }
      }
    }

    children.addAll([
      Icon(
        driverWidget ? Icons.directions_car : Icons.airline_seat_recline_normal,
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
            driverWidget ? "Driver" : "Passenger",
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            passenger.name,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
      Spacer(),
      Container(
        padding: EdgeInsets.all(10),
        child: driverWidget
            ? null
            : Icon(
                Icons.check_circle,
                color: validated ? Colors.green : Colors.grey,
              ),
      ),
      button,
    ]);

    return Container(
      height: 45,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget passengers(List<Passenger> passengers, List<Passenger> validated) {
    List<Widget> children = [];

    Set<String> validatedSet = new Set<String>();

    validated.forEach((element) {
      validatedSet.add(element.id);
    });

    //me at the last place of the list

    Passenger me;

    passengers.forEach((element) {
      if (element.id == myId) {
        me = element;
      }
    });

    if (me != null) {
      passengers.remove(me);
      passengers.add(me);
    }

    passengers.forEach((element) {
      children.add(
          passengersWidget(element, validatedSet.contains(element.id), false));
    });

    return Column(
      children: children,
    );
  }

  Widget acceptWidget() {
    return Row(
      children: <Widget>[
        Text(
          "Accept other requests",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        Spacer(),
        Switch(
          value: currentStatus,
          onChanged: widget.active
              ? (bool status) async {
                  String value = "Error";
                  var jwt = await MyPreferences.getAuthCode();

                  var res = await http.patch(
                      Uri.parse("${environment['url']}/runs/" + widget.id),
                      headers: {
                        'Authorization': jwt,
                      },
                      body: {
                        'active': status.toString()
                      });

                  if (res.statusCode == 200) {
                    setState(() {
                      currentStatus = status;
                    });
                    value = "Run active status changed";
                    print(currentStatus);
                  }

                  showBar(value);
                }
              : null,
        ),
      ],
    );
  }

  Future<void> appBarHandler(int value) async {
    if (value == 0) {
      _deleteAlert();
    } else if (value == 1) {
      _leaveAlert();
    }
  }

  Future<void> passengersHandler(int value, Passenger passenger) async {
    if (value == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(passenger.id, passenger.name),
        ),
      );
    } else if (value == 1) {
      var jwt = await MyPreferences.getAuthCode();

      //send messages

      var res = await http.get(Uri.parse("${environment['url']}/chats"), headers: {
        'Authorization': jwt,
      });

      if (res.statusCode == 200) {
        List<Chat> historyChats = (json.decode(res.body) as List)
            .map((i) => Chat.fromJson(i))
            .toList();

        Chat chat;

        historyChats.forEach((element) {
          element.partecipants.forEach((part) {
            if (part.partecipant.id == passenger.id) {
              chat = element;
            }
          });
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomPage(chat, myId),
            settings: RouteSettings(
              arguments: {'chat': chat},
            ),
          ),
        );
      }
    } else if (value == 2) {
      _removeAlert(passenger);
    }
  }

  Future<void> _deleteAlert() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Do you want to delete the run?'),
          content: Text('The passengers will be notified about the action.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Delete the Run'),
              onPressed: () async {
                //delete the run and pop back

                List<Chat> chatsToAck = [];
                Set<String> idSet = Set<String>();

                var jwt = await MyPreferences.getAuthCode();

                //send messages

                var res =
                    await http.get(Uri.parse("${environment['url']}/chats"), headers: {
                  'Authorization': jwt,
                });

                if (res.statusCode == 200) {
                  List<Chat> historyChats = (json.decode(res.body) as List)
                      .map((i) => Chat.fromJson(i))
                      .toList();

                  run.passengers.forEach((element) {
                    idSet.add(element.id);
                  });

                  historyChats.forEach((element) {
                    element.partecipants.forEach((part) {
                      if (idSet.contains(part.partecipant.id)) {
                        chatsToAck.add(element);
                      }
                    });
                  });

                  chatsToAck.forEach((element) {
                    //async
                    http.post(
                        Uri.parse("${environment['url']}/chats/" +
                            element.id +
                            '/messages'),
                        headers: {
                          'Authorization': jwt,
                        },
                        body: {
                          "message": "The run from " +
                              run.from.name +
                              " to " +
                              run.to.name +
                              " on date " +
                              DateFormat('dd-MM-yyyy – kk:mm')
                                  .format(run.eventDate.toLocal()) +
                              " has been deleted."
                        });
                  });
                } else {
                  throw Exception('Failed to load jobs from API');
                }

                //delete

                var response = await http
                    .delete(Uri.parse("${environment['url']}/runs/" + run.id), headers: {
                  'Authorization': jwt,
                });

                if (response.statusCode == 200) {
                  Navigator.pop(context);
                  Navigator.pop(context);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                      settings: RouteSettings(
                        arguments: {'showBar1': true},
                      ),
                    ),
                  );
                } else {
                  Navigator.pop(context);

                  showBar("Error, could not delete the run");
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _leaveAlert() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Do you want to leave the run?'),
          content: Text('The driver will be notified about the action.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Leave the Run'),
              onPressed: () async {
                //leave the run and pop back

                Chat chatToAck;

                var jwt = await MyPreferences.getAuthCode();

                //send messages

                var res =
                    await http.get(Uri.parse("${environment['url']}/chats"), headers: {
                  'Authorization': jwt,
                });

                if (res.statusCode == 200) {
                  List<Chat> historyChats = (json.decode(res.body) as List)
                      .map((i) => Chat.fromJson(i))
                      .toList();

                  historyChats.forEach((element) {
                    element.partecipants.forEach((part) {
                      if (part.partecipant.id == run.driver.id) {
                        chatToAck = element;
                      }
                    });
                  });

                  //async
                  http.post(
                      Uri.parse("${environment['url']}/chats/" +
                          chatToAck.id +
                          '/messages'),
                      headers: {
                        'Authorization': jwt,
                      },
                      body: {
                        "message": "I left the run from " +
                            run.from.name +
                            " to " +
                            run.to.name +
                            " on date " +
                            DateFormat('dd-MM-yyyy – kk:mm')
                                .format(run.eventDate.toLocal()) +
                            "."
                      });
                } else {
                  throw Exception('Failed to load jobs from API');
                }

                //leave run

                var response = await http.post(
                    Uri.parse("${environment['url']}/runs/" + run.id + "/leave"),
                    headers: {
                      'Authorization': jwt,
                    });

                if (response.statusCode == 200) {
                  Navigator.pop(context);
                  Navigator.pop(context);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                      settings: RouteSettings(
                        arguments: {'showBar2': true},
                      ),
                    ),
                  );
                } else {
                  Navigator.pop(context);

                  showBar("Error, could not leave the run");
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeAlert(Passenger passenger) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Do you want remove the passenger from the run?'),
          content: Text('The passenger will be notified about the action.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Remove from Run'),
              onPressed: () async {
                //remove from the run and pop back

                Chat chatToAck;

                var jwt = await MyPreferences.getAuthCode();

                //send messages

                var res =
                    await http.get(Uri.parse("${environment['url']}/chats"), headers: {
                  'Authorization': jwt,
                });

                if (res.statusCode == 200) {
                  List<Chat> historyChats = (json.decode(res.body) as List)
                      .map((i) => Chat.fromJson(i))
                      .toList();

                  historyChats.forEach((element) {
                    element.partecipants.forEach((part) {
                      if (part.partecipant.id == passenger.id) {
                        chatToAck = element;
                      }
                    });
                  });

                  //async
                  http.post(
                      Uri.parse("${environment['url']}/chats/" +
                          chatToAck.id +
                          '/messages'),
                      headers: {
                        'Authorization': jwt,
                      },
                      body: {
                        "message": "You have been removed from the run from " +
                            run.from.name +
                            " to " +
                            run.to.name +
                            " on date " +
                            DateFormat('dd-MM-yyyy – kk:mm')
                                .format(run.eventDate.toLocal()) +
                            "."
                      });
                } else {
                  throw Exception('Failed to load jobs from API');
                }

                var response = await http.post(
                    Uri.parse("${environment['url']}/runs/" +
                        run.id +
                        "/remove/" +
                        passenger.id),
                    headers: {
                      'Authorization': jwt,
                    });

                if (response.statusCode == 200) {
                  Navigator.pop(context);

                  setState(() {});

                  showBar("User " + passenger.name + " removed from the run");
                } else {
                  Navigator.pop(context);

                  showBar("Error, could not remove the user");
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget appBarButton() {
    Widget button = Container();

    if (widget.active) {
      if (widget.driver) {
        if (run.validated.length == 0) {
          //active driver (not validated passengers)

          button = PopupMenuButton(
            onSelected: (value) async {
              await appBarHandler(value);
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 0,
                  child: menuChild(Icons.delete, "Delete Run"),
                ),
              ];
            },
          );
        }
      } else {
        bool meValidated = false;

        run.validated.forEach((element) {
          if (element.id == myId) {
            meValidated = true;
          }
        });

        if (!meValidated) {
          //active passenger (not validated)

          button = PopupMenuButton(
            onSelected: (value) async {
              await appBarHandler(value);
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 1,
                  child: menuChild(Icons.clear, "Leave Run"),
                ),
              ];
            },
          );
        }
      }
    }

    return button;
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RunDetails>(
      future: getRunDetails(widget.id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          run = snapshot.data;
          currentStatus = run.active;
          return Scaffold(
            appBar: AppBar(
              title: Text("Details"),
              backgroundColor: Colors.lightBlueAccent,
              actions: <Widget>[
                appBarButton(),
              ],
            ),
            backgroundColor: Colors.white,
            body: Center(
              child: ListView(
                padding: EdgeInsets.all(30.0),
                children: <Widget>[
                  sectionTitle("Run information:"),
                  RunInfo(from: run.from, to: run.to, eventDate: run.eventDate),
                  SizedBox(
                    height: 20,
                  ),
                  sectionTitle("People in the car:"),
                  passengersWidget(run.driver, false, true),
                  SizedBox(
                    height: 10,
                  ),
                  widget.driver ? acceptWidget() : Container(),
                  widget.driver
                      ? SizedBox(
                          height: 20,
                        )
                      : Container(),
                  passengers(run.passengers, run.validated),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Details"),
              backgroundColor: Colors.lightBlueAccent,
            ),
            backgroundColor: Colors.white,
            body: Text("${snapshot.error}"),
          );
        }
        return Scaffold(
            appBar: AppBar(
              title: Text("Details"),
              backgroundColor: Colors.lightBlueAccent,
            ),
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(),
            ));
      },
    );
  }
}
