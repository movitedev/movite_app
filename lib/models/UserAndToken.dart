import 'package:movite_app/models/User.dart';

class UserAndToken {
  User user;
  String token;

  UserAndToken(User user, String token) {
    this.user = user;
    this.token = token;
  }

  UserAndToken.fromJson(Map json)
      : user = User.fromJson(json['user']),
        token = json['token'];

  Map toJson() {
    return {'user': user.toJson(), 'token': token};
  }
}
