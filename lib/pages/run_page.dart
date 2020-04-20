import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as gps;
import 'package:uuid/uuid.dart';

const kGoogleApiKey = "AIzaSyBsCUBVW9yHpOi5nFaQ7xuSJ6_1kCXJIx0";

class RunPage extends StatefulWidget {
  static String tag = 'profile-page';

  @override
  _RunPageState createState() => new _RunPageState();
}

class _RunPageState extends State<RunPage> {
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final dateController = TextEditingController();

  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

  String token = new Uuid().v4();

  gps.Location location = new gps.Location();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  bool _serviceEnabled;
  gps.PermissionStatus _permissionGranted;
  gps.LocationData _locationData;

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);

      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;

      print(p.toString());
      print(lat);
      print(lng);
    }
  }

  void onError(PlacesAutocompleteResponse response) {
    print(response.errorMessage);
  }

  Future _selectDateTime(BuildContext context) async {
    final DateTime datePicked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (datePicked == null) {
      return;
    }

    final TimeOfDay timePicked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    );

    if (timePicked == null) {
      return;
    }

    setState(() {
      dateController.text = DateFormat('dd-MM-yyyy – kk:mm').format(DateTime(
              datePicked.year,
              datePicked.month,
              datePicked.day,
              timePicked.hour,
              timePicked.minute)
          .toLocal());
    });
  }

  Widget placeInsert(String title) {
    return Column(children: <Widget>[
      TextField(
        controller: fromController,
        readOnly: true,
        autofocus: false,
        decoration: InputDecoration(
          icon: Icon(Icons.place),
          labelText: title,
          contentPadding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
        ),
        onTap: () async {
          Prediction p = await PlacesAutocomplete.show(
            context: context,
            apiKey: kGoogleApiKey,
            onError: onError,
            sessionToken: token,
            mode: Mode.overlay,
            language: "it",
            components: [Component(Component.country, "it")],
          );

          print(p.toString());
        },
      ),
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
              onPressed: () {},
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

                print(_locationData.latitude);
                print(_locationData.longitude);
              },
            ),
          ),
        ],
      ),
    ]);
  }

  Widget dateInsert(String title) {
    return Column(children: <Widget>[
      TextField(
        controller: dateController,
        readOnly: true,
        autofocus: false,
        decoration: InputDecoration(
          icon: Icon(Icons.calendar_today),
          labelText: title,
          contentPadding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
        ),
        onTap: () async {
          await _selectDateTime(context);
        },
      ),
      Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: FlatButton(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.timer),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Fra poco',
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                  ]),
              onPressed: () {
                dateController.text = DateFormat('dd-MM-yyyy – kk:mm')
                    .format(DateTime.now().toLocal());
              },
            ),
          ),
          Expanded(
            flex: 5,
            child: FlatButton(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.timer),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'In un paio di ore',
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                  ]),
              onPressed: () {
                dateController.text = DateFormat('dd-MM-yyyy – kk:mm')
                    .format((DateTime.now()).add(Duration(hours: 2)).toLocal());
              },
            ),
          ),
        ],
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final text = Text(
      'Run,',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black54,
        fontSize: 13.0,
      ),
    );

    return new Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: <Widget>[
            Text(
              "Dove vuoi andare?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 20.0,
              ),
            ),
            SizedBox(
              height: 25,
            ),
            placeInsert("A"),
            SizedBox(
              height: 30,
            ),
            Text(
              "Da dove parti?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 20.0,
              ),
            ),
            SizedBox(
              height: 25,
            ),
            placeInsert("Da"),
            SizedBox(
              height: 30,
            ),
            Text(
              "Quando?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 20.0,
              ),
            ),
            SizedBox(
              height: 25,
            ),
            dateInsert("Quando"),
          ],
        ),
      ),
    );
  }
}

/*
var uuid = new Uuid();

class CustomSearchScaffold extends PlacesAutocompleteWidget {
  CustomSearchScaffold()
      : super(
    apiKey: kGoogleApiKey,
    sessionToken: uuid.v4(),
    language: "en",
    components: [Component(Component.country, "it")],
  );

  @override
  _CustomSearchScaffoldState createState() => _CustomSearchScaffoldState();
}

class _CustomSearchScaffoldState extends PlacesAutocompleteState {
  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(title: AppBarPlacesAutoCompleteTextField());
    final body = PlacesAutocompleteResult(
      onTap: (p) {
        print(p.toString());
      },
      logo: Row(
        children: [FlutterLogo()],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
    return Scaffold(appBar: appBar, body: body);
  }

  @override
  void onResponseError(PlacesAutocompleteResponse response) {
    super.onResponseError(response);

    //

  }

  @override
  void onResponse(PlacesAutocompleteResponse response) {
    super.onResponse(response);
    if (response != null && response.predictions.isNotEmpty) {

      //
    }
  }
}

 */
