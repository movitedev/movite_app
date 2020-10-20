import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:movite_app/commons/global_variables.dart' as global;
import 'package:movite_app/models/Place.dart';
import 'package:movite_app/models/Location.dart' as myLoc;
import 'package:uuid/uuid.dart';

String kGoogleApiKey = DotEnv().env['kGoogleApiKey'];

class PlaceAutocomplete extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final bool from;

  PlaceAutocomplete(this.title, this.controller, this.from);

  @override
  _PlaceAutocompleteState createState() => _PlaceAutocompleteState();
}

class _PlaceAutocompleteState extends State<PlaceAutocomplete> {
  String token = new Uuid().v4();

  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

  Future<Place> displayPrediction(Prediction p) async {
    Place place;
    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);

      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;
      String name = detail.result.name;

      List coordinates = [lng, lat];
      myLoc.Location location = myLoc.Location("Point", coordinates);

      place = Place (name, location);
    }
    return place;
  }

  void onError(PlacesAutocompleteResponse response) {
    print(response.errorMessage);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: true,
      autofocus: false,
      decoration: InputDecoration(
        icon: Icon(Icons.place),
        labelText: widget.title,
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

        Place place = await displayPrediction(p);

        if (widget.from) {
          widget.controller.text = place.name;
          global.fromPlace = place;
        } else {
          widget.controller.text = place.name;
          global.toPlace = place;
        }
      },
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter a place';
        }
        return null;
      },
    );
  }
}
