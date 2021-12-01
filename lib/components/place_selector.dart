import 'package:flutter/material.dart';
import 'package:location/location.dart' as gps;
import 'package:mapbox_search/mapbox_search.dart';
import 'package:movite_app/commons/env.dart';
import 'package:movite_app/commons/global_variables.dart' as global;
import 'package:movite_app/commons/preferences.dart';
import 'package:movite_app/components/place_autocomplete.dart';
import 'package:movite_app/models/Location.dart' as myLoc;
import 'package:movite_app/models/Place.dart';

final String mapBoxApiKey = environment['mapBoxApiKey'];

class PlaceSelector extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final bool from;

  PlaceSelector(this.title, this.controller, this.from);

  @override
  _PlaceSelectorState createState() => _PlaceSelectorState();
}

class _PlaceSelectorState extends State<PlaceSelector> {

  var geoCodingService = ReverseGeoCoding(
    apiKey: mapBoxApiKey,
    limit: 1,
  );

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
            child: TextButton(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.home, color: Colors.black87),
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
                    await MyPreferences.getHome();
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
            child: TextButton(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.gps_fixed, color: Colors.black87),
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
                var result = await geoCodingService.getAddress(Location(lat: _locationData.latitude, lng: _locationData.longitude));
                String name = result.first.placeName;

                Place place = new Place(
                    name,
                    myLoc.Location("Point",
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
