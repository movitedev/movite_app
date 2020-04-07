import 'package:json_annotation/json_annotation.dart';

class Message implements Comparable<Message>{
  @JsonKey(name: '_id')
  String id;
  String message;
  String author;
  String chatId;
  DateTime createdAt;

  Message(String id, String message, String author, String chatId,
      DateTime createdAt) {
    this.id = id;
    this.author = author;
    this.chatId = chatId;
    this.createdAt = createdAt;
  }

  Message.fromJson(Map json)
      : id = json['_id'],
        message = json['message'],
        author = json['author'],
        chatId = json['chatId'],
        createdAt = DateTime.parse(json['createdAt']);

  Map toJson() {
    return {
      '_id': id,
      'message': message,
      'author': author,
      'chatId': chatId,
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
