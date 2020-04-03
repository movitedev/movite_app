import 'package:json_annotation/json_annotation.dart';

import 'UsersReduced.dart';

class Chat {
  @JsonKey(name: '_id')
  String id;
  List<Partecipant> partecipants;
  DateTime lastUpdate;
  DateTime createdAt;

  Chat(String id, List<Partecipant> partecipants, DateTime lastUpdate,
      DateTime createdAt) {
    this.id = id;
    this.partecipants = partecipants;
    this.lastUpdate = lastUpdate;
    this.createdAt = createdAt;
  }

  Chat.fromJson(Map json)
      : id = json['_id'],
        partecipants = (json['partecipants'] as List)
            .map((i) => Partecipant.fromJson(i))
            .toList(),
        lastUpdate = DateTime.parse(json['lastUpdate']),
        createdAt = DateTime.parse(json['createdAt']);

  Map toJson() {
    return {
      '_id': id,
      'partecipants': partecipants.map((tag) => tag.toJson()).toList(),
      'lastUpdate': lastUpdate,
      'createdAt': createdAt
    };
  }
}
