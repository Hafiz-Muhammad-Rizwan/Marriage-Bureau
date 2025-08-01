import 'package:shared_preferences/shared_preferences.dart';

class LogInStatus{
  static Future<void> setLoggedIn(bool value)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', value);
  }
  static Future<bool> isLoggedIn() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
