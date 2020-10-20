import 'package:flutter/material.dart';
import 'package:location/location.dart' as gps;
import 'package:movite_app/commons/global_variables.dart' as global;
import 'package:movite_app/commons/preferences.dart';
import 'package:movite_app/components/place_autocomplete.dart';
import 'package:movite_app/models/Location.dart';
import 'package:movite_app/models/Place.dart';

class PlaceSelector extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final bool from;

  PlaceSelector(this.title, this.controller, this.from);

  @override
  _PlaceSelectorState createState() => _PlaceSelectorState();
}

class _PlaceSelectorState extends State<PlaceSelector> {

  gps.Location location = new gps.Location();
  bool _serviceEnabled;
  gps.PermissionStatus _permissionGranted;
  gps.LocationData _locationData;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      PlaceAutocomplete(widget.title, widget.controller, widget.from),
      Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: FlatButton(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.home),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Home',
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                  ]),
              onPressed: () async {
                Place place =
                    new Place("Home", (await MyPreferences.getHome()).location);
                if (widget.from) {
                  global.fromPlace = place;
                } else {
                  global.toPlace = place;
                }

                widget.controller.text = place.name;
              },
            ),
          ),
          Expanded(
            flex: 5,
            child: FlatButton(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.gps_fixed),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'My Position',
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                  ]),
              onPressed: () async {
                _serviceEnabled = await location.serviceEnabled();
                if (!_serviceEnabled) {
                  _serviceEnabled = await location.requestService();
                  if (!_serviceEnabled) {
                    return;
                  }
                }

                _permissionGranted = await location.hasPermission();
                if (_permissionGranted == gps.PermissionStatus.denied) {
                  _permissionGranted = await location.requestPermission();
                  if (_permissionGranted != gps.PermissionStatus.granted) {
                    return;
                  }
                }

                _locationData = await location.getLocation();

                Place place = new Place(
                    "My Location",
                    Location("Point",
                        [_locationData.longitude, _locationData.latitude]));

                if (widget.from) {
                  global.fromPlace = place;
                } else {
                  global.toPlace = place;
                }

                widget.controller.text = place.name;

              },
            ),
          ),
        ],
      ),
    ]);
  }
}
