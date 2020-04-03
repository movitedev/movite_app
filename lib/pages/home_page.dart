import 'package:flutter/material.dart';
import 'package:movite_app/commons/preferences.dart';
import 'package:movite_app/pages/chat_page.dart';
import 'package:movite_app/pages/code_page.dart';
import 'package:movite_app/pages/event_page.dart';
import 'package:movite_app/pages/landing_page.dart';
import 'package:movite_app/pages/movite_page.dart';
import 'package:movite_app/pages/profile_page.dart';
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
    }
  }

  final List<Widget> _children = [
    MovitePage(),
    ChatPage(),
    RunPage(),
    EventPage(),
    CodePage()
  ];

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

  @override
  Widget build(BuildContext context) {
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
                MaterialPageRoute(builder: (context) => ProfilePage()),
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
                  child: Text("Logout"),
                ),
                PopupMenuItem(
                  value: 1,
                  child: Text("About"),
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
