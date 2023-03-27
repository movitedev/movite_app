import 'package:json_annotation/json_annotation.dart';

class Passenger {
  @JsonKey(name: '_id')
  String? id;
  String? name;


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

class Partecipant {
  late Passenger partecipant;
  DateTime? lastView;

  Partecipant(Passenger partecipant, DateTime lastView) {
    this.partecipant = partecipant;
    this.lastView = lastView;
  }

  Partecipant.fromJson(Map json)
      : partecipant = Passenger.fromJson(json['partecipant']),
        lastView = DateTime.parse(json['lastView']);

  Map toJson() {
    return {
      'partecipant': partecipant.toJson(),
      'lastView': lastView
    };
  }
}
