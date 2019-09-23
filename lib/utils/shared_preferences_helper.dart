import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static final String _accessToken = "accessToken";
  static final String _currentUserId = "currentUsertId";
  static final String _syncContactsFlag = "syncContactsFlag";

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

  static Future<String> getCurrentUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_currentUserId) ?? "";
  }

  static Future<bool> saveCurrentUserId(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_currentUserId, value);
  }

  static Future<bool> getSyncContactsFlag() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_syncContactsFlag) ?? false;
  }

  static Future<bool> saveSyncContactsFlag(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool(_syncContactsFlag, value);
  }
}
