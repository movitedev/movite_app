import 'package:json_annotation/json_annotation.dart';
import 'package:movite_app/models/Place.dart';
import 'package:movite_app/models/User.dart';

import 'UsersReduced.dart';

class Run {
  @JsonKey(name: '_id')
  String? id;
  Place? from;
  Place? to;
  User? driver;
  DateTime? eventDate;
  DateTime? createdAt;

  Run(String id, Place from, Place name, User driver, DateTime eventDate,
      DateTime createdAt) {
    this.id = id;
    this.from = from;
    this.to = to;
    this.driver = driver;
    this.eventDate = eventDate;
    this.createdAt = createdAt;
  }

  Run.fromJson(Map json)
      : id = json['_id'],
        from = Place.fromJson(json['from']),
        to = Place.fromJson(json['to']),
        driver = User.fromJson(json['driver']),
        eventDate = DateTime.parse(json['eventDate']),
        createdAt = DateTime.parse(json['createdAt']);

  Map toJson() {
    return {
      '_id': id,
      'from': from!.toJson(),
      'to': to!.toJson(),
      'driver': driver,
      'eventDate': eventDate,
      'createdAt': createdAt
    };
  }
}

class RunNoPopulate {
  @JsonKey(name: '_id')
  String? id;
  late Place from;
  Place? to;
  String? driver;
  DateTime? eventDate;
  DateTime? createdAt;

  RunNoPopulate(String id, Place from, Place name, String driver,
      DateTime eventDate, DateTime createdAt) {
    this.id = id;
    this.from = from;
    this.to = to;
    this.driver = driver;
    this.eventDate = eventDate;
    this.createdAt = createdAt;
  }

  RunNoPopulate.fromJson(Map json)
      : id = json['_id'],
        from = Place.fromJson(json['from']),
        to = Place.fromJson(json['to']),
        driver = json['driver'],
        eventDate = DateTime.parse(json['eventDate']),
        createdAt = DateTime.parse(json['createdAt']);

  Map toJson() {
    return {
      '_id': id,
      'from': from.toJson(),
      'to': to!.toJson(),
      'driver': driver,
      'eventDate': eventDate,
      'createdAt': createdAt
    };
  }
}

class RunDetails {
  @JsonKey(name: '_id')
  String? id;
  Place? from;
  Place? to;
  late Passenger driver;
  bool? active;
  late List<Passenger?> passengers;
  late List<Passenger> validated;
  DateTime? eventDate;
  DateTime? createdAt;

  RunDetails(
      String id,
      Place from,
      Place name,
      Passenger driver,
      bool active,
      List<Passenger?> passengers,
      List<Passenger> validated,
      DateTime eventDate,
      DateTime createdAt) {
    this.id = id;
    this.from = from;
    this.to = to;
    this.driver = driver;
    this.active = active;
    this.passengers = passengers;
    this.validated = validated;
    this.eventDate = eventDate;
    this.createdAt = createdAt;
  }

  RunDetails.fromJson(Map json)
      : id = json['_id'],
        from = Place.fromJson(json['from']),
        to = Place.fromJson(json['to']),
        driver = Passenger.fromJson(json['driver']),
        active = json['active'],
        passengers = (json['passengers'] as List)
            .map((i) => Passenger.fromJson(i['passenger']))
            .toList(),
        validated = (json['validated'] as List)
            .map((i) => Passenger.fromJson(i['passenger']))
            .toList(),
        eventDate = DateTime.parse(json['eventDate']),
        createdAt = DateTime.parse(json['createdAt']);

  Map toJson() {
    return {
      '_id': id,
      'from': from!.toJson(),
      'to': to!.toJson(),
      'driver': driver.toJson(),
      'active': active,
      'passengers': passengers.map((tag) => tag!.toJson()).toList(),
      'validated': validated.map((tag) => tag.toJson()).toList(),
      'eventDate': eventDate,
      'createdAt': createdAt
    };
  }
}
