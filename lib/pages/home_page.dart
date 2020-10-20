import 'package:flutter/material.dart';
import 'package:movite_app/commons/preferences.dart';
import 'package:movite_app/commons/sockets.dart';
import 'package:movite_app/pages/about_page.dart';
import 'package:movite_app/pages/chat_page.dart';
import 'package:movite_app/pages/code_page.dart';
import 'package:movite_app/pages/event_page.dart';
import 'package:movite_app/pages/landing_page.dart';
import 'package:movite_app/pages/movite_page.dart';
import 'package:movite_app/pages/myprofile_page.dart';
import 'package:movite_app/pages/run_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> handler(value) async {
    if (value == 0) {
      _loginAlert();
    } else if (value == 1){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AboutPage()),
      );
    }
  }

  final List<Widget> _children = [
    MovitePage(),
    ChatPage(),
    RunPage(),
    EventPage(),
    CodePage()
  ];

  @override
  void initState() {
    MySockets().init();

    super.initState();
  }

  Future<void> _loginAlert() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Do you want to logout?'),
          content: Text('After the operation you will need to login again.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('Logout'),
              onPressed: () async {
                await MyPreferences.logout();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LandingPage()),
                    (route) => false);
              },
            ),
          ],
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;

    if (args != null) {
      if (args.containsKey('showBar1')) {
        if (args['showBar1']) {
          _selectedIndex = 0;
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _selectedIndex = 2);
        }
      }

      if (args.containsKey('showBar2')) {
        if (args['showBar2']) {
          _selectedIndex = 0;
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _selectedIndex = 2);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: const Text('Movite'),
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyProfilePage()),
              );
            },
          ),
          PopupMenuButton(
            onSelected: (value) async {
              await handler(value);
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 0,
                  child: menuChild(Icons.exit_to_app, "Logout"),
                ),
                PopupMenuItem(
                  value: 1,
                  child: menuChild(Icons.info, "About"),
                )
              ];
            },
          ),
        ],
      ),
      body: _children[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black26,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Colors.lightBlueAccent,
            icon: Icon(Icons.directions_car),
            title: Text('Movite'),
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.lightBlueAccent,
            icon: Icon(Icons.chat),
            title: Text('Chats'),
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.lightBlueAccent,
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.lightBlueAccent,
            icon: Icon(Icons.event),
            title: Text('Events'),
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.lightBlueAccent,
            icon: Icon(Icons.local_offer),
            title: Text('QR Code'),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
