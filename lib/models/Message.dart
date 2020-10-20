import 'package:json_annotation/json_annotation.dart';

class Message implements Comparable<Message>{
  @JsonKey(name: '_id')
  String id;
  String message;
  String author;
  String chatId;
  bool activeRequest;
  String run;
  DateTime createdAt;

  Message(String id, String message, String author, String chatId, bool activeRequest, String run,
      DateTime createdAt) {
    this.id = id;
    this.message = message;
    this.author = author;
    this.chatId = chatId;
    this.activeRequest = activeRequest;
    this.run = run;
    this.createdAt = createdAt;
  }

  Message.fromJson(Map json)
      : id = json['_id'],
        message = json['message'],
        author = json['author'],
        chatId = json['chatId'],
        activeRequest = json['activeRequest'],
        run = json['run'],
      createdAt = DateTime.parse(json['createdAt']);

  Map toJson() {
    return {
      '_id': id,
      'message': message,
      'author': author,
      'chatId': chatId,
      'activeRequest': activeRequest,
      'run': run,
      'createdAt': createdAt
    };
  }

  @override
  int compareTo(other) {

    if (this.createdAt == null || other == null) {
      return null;
    }

    if (this.createdAt.isBefore(other.createdAt)) {
      return 1;
    }

    if (this.createdAt.isAfter(other.createdAt)) {
      return -1;
    }

    if (this.createdAt == other.createdAt) {
      return 0;
    }

    return null;
  }

}
