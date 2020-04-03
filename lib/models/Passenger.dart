import 'package:json_annotation/json_annotation.dart';

class Passenger {
  @JsonKey(name: '_id')
  String id;
  String name;


  Passenger(String id, String name) {
    this.id = id;
    this.name = name;
  }

  Passenger.fromJson(Map json)
      : id = json['_id'],
        name = json['name'];

  Map toJson() {
    return {
      '_id': id,
      'name': name
    };
  }
}
