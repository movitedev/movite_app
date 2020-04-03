import 'package:json_annotation/json_annotation.dart';

class User {
  @JsonKey(name: '_id')
  String id;
  String name;
  String email;
  int age;
  String role;
  DateTime createdAt;

  User(String id, String name, String email, int age, String role,
      DateTime createdAt) {
    this.id = id;
    this.name = name;
    this.email = email;
    this.age = age;
    this.role = role;
    this.createdAt = createdAt;
  }

  User.fromJson(Map json)
      : id = json['_id'],
        name = json['name'],
        email = json['email'],
        age = json['age'],
        role = json['role'],
        createdAt = DateTime.parse(json['createdAt']);

  Map toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'age': age,
      'role': role,
      'createdAt': createdAt
    };
  }
}
