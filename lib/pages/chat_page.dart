import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:movite_app/commons/env.dart';
import 'package:movite_app/commons/preferences.dart';
import 'package:movite_app/models/Chat.dart';

class ChatPage extends StatefulWidget {
  static String tag = 'profile-page';

  @override
  _ChatPageState createState() => new _ChatPageState();
}

ListView chatList(data, myId) {
  data.sort((Chat a, Chat b) => b.lastUpdate.compareTo(a.lastUpdate));

  return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        int myIndex =
            (data[index].partecipants[0].partecipant.id) == myId ? 0 : 1;

        return tile(
            data[index].partecipants[1 - myIndex].partecipant.name,
            DateFormat('dd-MM-yyyy – kk:mm').format(data[index].lastUpdate),
            (data[index].partecipants[myIndex].lastView)
                .isAfter(data[index].lastUpdate),
            context);
      });
}

ListTile tile(String title, String subtitle, bool read, BuildContext context) {

  if(read) {
    return ListTile(
      title: Text(title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
          )),
      subtitle: Text(subtitle),
      leading: Icon(
        Icons.mail_outline,
      ),
      onTap: () {
        /*
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsPage(),
            settings: RouteSettings(
              arguments: {'id': id},
            ),
          ),
        );*/
      },
    );
  }
  else{
    return ListTile(
      title: Text(title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
          )),
      subtitle: Text(subtitle),
      leading: Icon(
        Icons.mail,
        color: Colors.blue[500],
      ),
      onTap: () {
        /*
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsPage(),
            settings: RouteSettings(
              arguments: {'id': id},
            ),
          ),
        );*/
      },
    );
  }
}

class _ChatPageState extends State<ChatPage> {
  String myId = '';

  Future<List<Chat>> getRuns() async {
    var jwt = await MyPreferences.getAuthCode();

    myId = await MyPreferences.getId();

    var res = await http.get("${environment['url']}/chats", headers: {
      'Authorization': jwt,
    });

    if (res.statusCode == 200) {
      List<Chat> chats =
          (json.decode(res.body) as List).map((i) => Chat.fromJson(i)).toList();
      return chats;
    } else {
      throw Exception('Failed to load jobs from API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Chat>>(
      future: getRuns(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Chat> data = snapshot.data;

          return new Scaffold(
            backgroundColor: Colors.white,
            body: Container(
              child: chatList(data, myId),
            ),
          );
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
