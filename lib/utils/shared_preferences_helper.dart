import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static final String _accessToken = "accessToken";

  static Future clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  static Future<String> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_accessToken) ?? "";
  }

  static Future<bool> saveAccessToken(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_accessToken, value);
  }
}
