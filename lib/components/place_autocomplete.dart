import 'package:flutter/material.dart';
import 'package:movite_app/commons/env.dart';
import 'package:movite_app/commons/global_variables.dart' as global;
import 'package:movite_app/models/Location.dart' as myLoc;
import 'package:movite_app/models/Place.dart';
import 'mapbox_search_widget.dart';

final String mapBoxApiKey = environment['mapBoxApiKey'];

class PlaceSearchDialog extends StatefulWidget {
  final TextEditingController controller;

  PlaceSearchDialog(this.controller);
  @override
  _PlaceSearchDialogState createState() => _PlaceSearchDialogState();
}

class _PlaceSearchDialogState extends State<PlaceSearchDialog> {

  bool _focused = false;

  void afterBuild() {
    if (!_focused) {
      FocusScope.of(context).nextFocus();
      _focused= true;
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => afterBuild());

    return SimpleDialog(alignment: Alignment.topCenter, children: <Widget>[
      MapBoxPlaceSearchWidget(
        popOnSelect: true,
        context: context,
        apiKey: mapBoxApiKey,
        searchHint: 'Search',
        fontSize: 20,
        onSelected: (p) async {
          Place place = Place(p.placeName,
              myLoc.Location("Point", p.geometry.coordinates));
          widget.controller.text = place.name;
        },
      ),
    ]);
  }
}

class PlaceAutocomplete extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final bool from;

  PlaceAutocomplete(this.title, this.controller, this.from);

  @override
  _PlaceAutocompleteState createState() => _PlaceAutocompleteState();
}

class _PlaceAutocompleteState extends State<PlaceAutocomplete> {
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
        Place p = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return PlaceSearchDialog(widget.controller);
            });

        if (p != null) {

          if (widget.from) {
            global.fromPlace = p;
          } else {
            global.toPlace = p;
          }
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
