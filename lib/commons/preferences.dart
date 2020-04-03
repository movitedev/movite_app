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

  static Future<String> getemail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
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

  static Future saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('name', user.name);
    prefs.setInt('age', user.age);
    prefs.setString('email', user.email);
  }

  static Future logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('jwt', '');
    prefs.setString('name', '');
    prefs.setInt('age', 0);
    prefs.setString('email', '');
  }

}
