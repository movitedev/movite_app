import 'package:json_annotation/json_annotation.dart';
import 'package:movite_app/models/Place.dart';
import 'package:movite_app/models/User.dart';

class Run {
  @JsonKey(name: '_id')
  String id;
  Place from;
  Place to;
  User driver;
  DateTime eventDate;
  DateTime createdAt;

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
      'from': from.toJson(),
      'to': to.toJson(),
      'driver': driver,
      'eventDate': eventDate,
      'createdAt': createdAt
    };
  }
}

class RunNoPopulate {
  @JsonKey(name: '_id')
  String id;
  Place from;
  Place to;
  String driver;
  DateTime eventDate;
  DateTime createdAt;

  RunNoPopulate(String id, Place from, Place name, String driver, DateTime eventDate,
      DateTime createdAt) {
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
      'to': to.toJson(),
      'driver': driver,
      'eventDate': eventDate,
      'createdAt': createdAt
    };
  }
}
