import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:movite_app/commons/env.dart';
import 'package:movite_app/commons/preferences.dart';
import 'package:movite_app/models/Chat.dart';
import 'package:movite_app/models/Message.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

IO.Socket chatSocket, messageSocket;

Map<String, bool> messageSocketsMap = Map<String, bool>();

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
            data[index],
            myId,
            context);
      });
}

ListTile tile(String title, String subtitle, bool read, Chat chat, String myId,
    BuildContext context) {
  if (read) {
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomPage(chat, myId),
            settings: RouteSettings(
              arguments: {'chat': chat},
            ),
          ),
        );
      },
    );
  } else {
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomPage(chat, myId),
            settings: RouteSettings(
              arguments: {'chat': chat},
            ),
          ),
        );
      },
    );
  }
}

class _ChatPageState extends State<ChatPage> {
  String myId = '';
  String token = '';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ioConnect();
    });

    super.initState();
  }

  Future ioConnect() async {
    print("Connect");

    chatSocket = IO.io(environment['url'] + '/chats', <String, dynamic>{
      'transports': ['websocket'],
      'query': {'token': await MyPreferences.getAuthCode()}
    });

    messageSocket = IO.io(environment['url'] + '/messages', <String, dynamic>{
      'transports': ['websocket'],
      'query': {'token': await MyPreferences.getAuthCode()}
    });
  }

  Future<List<Chat>> getRuns() async {
    var jwt = await MyPreferences.getAuthCode();

    myId = await MyPreferences.getId();
    token = await MyPreferences.getAuthCode();

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

class ChatRoomPage extends StatefulWidget {
  final Chat chat;
  final String myId;

  const ChatRoomPage(this.chat, this.myId);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Message> messages;
  double height, width;
  TextEditingController textController;
  ScrollController scrollController;
  Widget chatChild;
  String chatTitle;

  @override
  void initState() {
    messages = new List<Message>();
    textController = TextEditingController();
    scrollController = ScrollController();

    int myIndex =
        (widget.chat.partecipants[0].partecipant.id) == widget.myId ? 0 : 1;

    chatTitle = widget.chat.partecipants[1 - myIndex].partecipant.name;

    if (messageSocketsMap.containsKey(widget.chat.id)) {
      messageSocket.clearListeners();
    } else {
      messageSocketsMap[widget.chat.id] = true;
    }

    messageSocket.emit('room', widget.chat.id);

    messageSocket.on('message', (jsonData) {
      Message message = Message.fromJson(jsonData);

      setState(() {
        messages.insert(0, message);
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatHistory();
    });

    setLastView();

    super.initState();
  }

  Future chatHistory() async {
    var jwt = await MyPreferences.getAuthCode();

    var res = await http.get(
        "${environment['url']}/chats/" + widget.chat.id + '/messages',
        headers: {
          'Authorization': jwt,
        });

    if (res.statusCode == 200) {
      List<Message> history = (json.decode(res.body) as List)
          .map((i) => Message.fromJson(i))
          .toList();

      messages.addAll(history);
      messages = messages.toSet().toList();
      messages.sort((Message a, Message b) => a.compareTo(b));

      setState(() {});
    } else {
      throw Exception('Failed to load jobs from API');
    }
  }

  Future<bool> setLastView() async {
    var jwt = await MyPreferences.getAuthCode();

    var res = await http.post(
        "${environment['url']}/chats/" + widget.chat.id + "/read",
        headers: {
          'Authorization': jwt,
        });

    if (res.statusCode == 200) {
      print("read");
    }

    return true;
  }

  Widget buildSingleMessage(int index) {
    bool left = messages[index].author != widget.myId;
    return Container(
      alignment: left ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
          padding: const EdgeInsets.only(
              top: 20.0, bottom: 10.0, left: 20.0, right: 20.0),
          margin: left
              ? const EdgeInsets.only(
                  top: 10.0, bottom: 10.0, left: 10.0, right: 50.0)
              : const EdgeInsets.only(
                  top: 10.0, bottom: 10.0, left: 50.0, right: 10.0),
          decoration: BoxDecoration(
            color: left ? Colors.blue : Colors.green,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                messages[index].message,
                style: TextStyle(color: Colors.white, fontSize: 15.0),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                DateFormat('dd-MM-yyyy – kk:mm')
                    .format(messages[index].createdAt),
                style: TextStyle(color: Colors.white70, fontSize: 12.0),
              ),
            ],
          )),
    );
  }

  Widget buildMessageList() {
    return Container(
      height: height,
      width: width,
      child: ListView.builder(
        controller: scrollController,
        reverse: true,
        shrinkWrap: true,
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          return buildSingleMessage(index);
        },
      ),
    );
  }

  Widget buildChatInput() {
    return Container(
      width: width - 80 - 30,
      padding: const EdgeInsets.all(2.0),
      margin: const EdgeInsets.only(left: 30.0),
      child: TextField(
        maxLines: null,
        decoration: InputDecoration.collapsed(
          hintText: 'Send a message...',
        ),
        controller: textController,
      ),
    );
  }

  Widget buildSendButton() {
    return FloatingActionButton(
      backgroundColor: Colors.lightBlueAccent,
      onPressed: () async {
        //Check if the textfield has text or not
        if (textController.text.isNotEmpty) {
          //Send the message as JSON data to send_message event
          String text = textController.text;
          textController.text = '';

          var jwt = await MyPreferences.getAuthCode();

          var res = await http.post(
              "${environment['url']}/chats/" + widget.chat.id + '/messages',
              headers: {
                'Authorization': jwt,
              },
              body: {
                "message": text
              });

          if (res.statusCode != 201) {
            _scaffoldKey.currentState.showSnackBar(new SnackBar(
              content: new Text("Unable to send the message"),
              behavior: SnackBarBehavior.floating,
              elevation: 8,
            ));
          }

          //Add the message to the list

          //Scrolldown the list to show the latest message
          /*scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 600),
            curve: Curves.ease,
          );*/
        }
      },
      child: Icon(
        Icons.send,
        size: 25,
      ),
    );
  }

  Widget buildInputArea() {
    return Container(
      height: 80,
      width: width,
      child: Row(
        children: <Widget>[
          buildChatInput(),
          buildSendButton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height - 80 - 80;
    width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: setLastView,
      child: Scaffold(
        appBar: AppBar(
          title: Text(chatTitle),
          backgroundColor: Colors.lightBlueAccent,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              buildMessageList(),
              buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }
}
