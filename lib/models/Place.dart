import 'package:movite_app/models/Location.dart';

class Place {
  String name;
  Location location;

  Place(String name, Location location) {
    this.name = name;
    this.location = location;
  }

  Place.fromJson(Map json)
      : name = json['name'],
        location = Location.fromJson(json['location']);

  Map toJson() {
    return {'name': name, 'location': location.toJson()};
  }
}
