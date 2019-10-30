import 'dart:convert' as convert;

import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static final String _accessToken = "accessToken";
  static final String _currentUserId = "currentUsertId";
  static final String _currentUserName = "currentUsertName";
  static final String _syncContactsFlag = "syncContactsFlag";
  static final String _allowPushNotifications = "allowPushNotifications";
  static final String _allowMessageNotification = "allowMessageNotification";
  static final String _allowRecommendSearchNotification =
      "allowRecommendSearchNotification";

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

  static Future<String> getCurrentUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_currentUserName) ?? "";
  }

  static Future<bool> saveCurrentUserName(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_currentUserName, value);
  }

  static Future<PubNubConversation> getConversation(
      String conversationId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var conversationEncoded = prefs.getString(conversationId);
    if (conversationEncoded != null && conversationEncoded.length > 0) {
      return PubNubConversation.fromJson(
          convert.jsonDecode(conversationEncoded));
    } else {
      return null;
    }
  }

  static Future<bool> saveConversation(PubNubConversation conversation) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(
        conversation.id, convert.jsonEncode(conversation.toJson()));
  }

  static Future<String> getLastMessageTimestamp(String conversationId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("last_message:$conversationId") ?? "";
  }

  static Future<bool> saveLastMessage(
      String conversationId, DateTime lastMessageTimestamp) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(
        "last_message:$conversationId", lastMessageTimestamp.toIso8601String());
  }

  static Future<int> getCardRecommendsCount(String cardId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(cardId) ?? null;
  }

  static Future<bool> saveCardRecommendsCount(
      String cardId, int numberOfRecommends) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(cardId, numberOfRecommends);
  }

  static Future<bool> getSyncContactsFlag() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_syncContactsFlag) ?? false;
  }

  static Future<bool> saveSyncContactsFlag(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool(_syncContactsFlag, value);
  }

  static Future<bool> setPushNotificationAllowed(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool(_allowPushNotifications, value);
  }

  static Future<bool> setMessageNotificationAllowed(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool(_allowMessageNotification, value);
  }

  static Future<bool> setRecommendsSearchNotificationAllowed(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool(_allowRecommendSearchNotification, value);
  }
}
