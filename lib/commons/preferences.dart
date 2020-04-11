import 'package:movite_app/models/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPreferences {

  static Future<String> getAuthCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }

  static Future<int> getAge() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('age');
  }

  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }
  static Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  static Future<String> getId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('id');
  }

  static Future<DateTime> getCreatedAt() async {
    final prefs = await SharedPreferences.getInstance();
    return DateTime.parse(prefs.getString('createdAt'));
  }

  static Future<User> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    User me = new User(prefs.getString('id'), prefs.getString('name'), prefs.getString('email'), prefs.getInt('age'), prefs.getString('role'), DateTime.parse(prefs.getString('createdAt')));
    return me;
  }


  static Future setAuthCode(String authCode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('jwt', authCode);
  }

  static Future setName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('name', name);
  }

  static Future setAge(int age) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('age', age);

  }

  static Future setEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
  }

  static Future setRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('role', role);
  }

  static Future setId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('id', id);
  }

  static Future setCreatedAt(DateTime createdAt) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('createdAt', createdAt.toString());
  }

  static Future saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('name', user.name);
    prefs.setInt('age', user.age);
    prefs.setString('email', user.email);
    prefs.setString('role', user.role);
    prefs.setString('id', user.id);
    prefs.setString('createdAt', user.createdAt.toString());
  }

  static Future logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('jwt', '');
    prefs.setString('name', '');
    prefs.setInt('age', 0);
    prefs.setString('email', '');
    prefs.setString('role', '');
    prefs.setString('id', '');
    prefs.setString('createdAt', '');

  }

}
