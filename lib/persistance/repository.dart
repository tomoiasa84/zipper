import 'dart:convert' as convert;
import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/model/conversation_model.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/BatchHistoryResponse.dart';
import 'package:contractor_search/models/PnGCM.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;

import 'api_provider.dart';

class Repository {
  ApiProvider appApiProvider = ApiProvider();

  getContacts() async {
    return ContactsService.getContacts();
  }

  Future<QueryResult> getUserById(String userId) async {
    var result = await appApiProvider.getUserById(userId);
    checkExpiredSession(result);
    return result;
  }

  Future<QueryResult> getCardById(int cardId) async {
    var result = await appApiProvider.getCardById(cardId);
    checkExpiredSession(result);
    return result;
  }

  Future<QueryResult> deleteCard(int cardId) async {
    var result = await appApiProvider.deleteCard(cardId);
    checkExpiredSession(result);
    return result;
  }

  Future<QueryResult> getTags() async {
    var result = await appApiProvider.getTags();
    checkExpiredSession(result);
    return result;
  }

  Future<QueryResult> createCard(
      String postedBy, int searchFor, String details) async {
    var result = await appApiProvider.createCard(postedBy, searchFor, details);
    checkExpiredSession(result);
    return result;
  }

  Future<PubNubConversation> getConversation(String conversationId) async {
    QueryResult result = await appApiProvider.getConversation(conversationId);

    ConversationModel conversationModel =
        ConversationModel.fromJson(result.data['get_conversation']);
    PubNubConversation pubNubConversation =
        PubNubConversation.fromConversation(conversationModel);
    return pubNubConversation;
  }

  Future createConnection(String currentUserId, String targetUserId) async {
    var result =
        await appApiProvider.createConnection(currentUserId, targetUserId);
    checkExpiredSession(result);
    return result;
  }

  Future<PubNubConversation> createConversation(User user) async {
    String currentUserId = await getCurrentUserId();
    QueryResult result =
        await appApiProvider.createConversation(user, currentUserId);

    ConversationModel conversationModel =
        ConversationModel.fromJson(result.data['create_conversation']);
    PubNubConversation pubNubConversation =
        PubNubConversation.fromConversation(conversationModel);
    return pubNubConversation;
  }

  Future<List<ConversationModel>> getListOfIdsFromBackend() async {
    String currentUserId = await getCurrentUserId();
    var result = await appApiProvider.getListOfIdsFromBackend(currentUserId);
    checkExpiredSession(result);
    User currentUser = User.fromJson(result.data['get_user']);
    return currentUser.conversations;
  }

  Future<String> getStringOfChannelIds() async {
    var listOfConversations = await getListOfIdsFromBackend();

    String channelIds = "";

    for (var item in listOfConversations) {
      channelIds = channelIds + item.id.toString() + ",";
    }

    return channelIds;
  }

  Future<QueryResult> getCards() async {
    var result = await appApiProvider.getCards();
    checkExpiredSession(result);
    return result;
  }

  Future<QueryResult> updateUser(
      String name,
      int location,
      String id,
      String phoneNumber,
      bool isActive,
      String description,
      String profilePicUrl) async {
    var result = await appApiProvider.updateUser(
        name, location, id, phoneNumber, isActive, description, profilePicUrl);
    checkExpiredSession(result);
    return result;
  }

  Future<QueryResult> updateDeviceToken(String id, String deviceToken) async {
    var result = await appApiProvider.updateDeviceToken(id, deviceToken);
    checkExpiredSession(result);
    return result;
  }

  Future<QueryResult> createUserTag(String userId, int tagId) async {
    var result = await appApiProvider.createUserTag(userId, tagId);
    checkExpiredSession(result);
    return result;
  }

  Future<QueryResult> updateMainUserTag(int userTagId) async {
    var result = await appApiProvider.updateMainUserTag(userTagId);
    checkExpiredSession(result);
    return result;
  }

  Future<QueryResult> deleteUserTag(int userTagId) async {
    var result = await appApiProvider.deleteUserTag(userTagId);
    checkExpiredSession(result);
    return result;
  }

  Future<QueryResult> getUsers() async {
    var result = await appApiProvider.getUsers();
    checkExpiredSession(result);
    return result;
  }

  Future<QueryResult> loadContacts(List<String> phoneContacts) async {
    var result = await appApiProvider.loadContacts(phoneContacts);
    checkExpiredSession(result);
    return result;
  }

  Future<QueryResult> loadConnections(List<String> existingUsers) async {
    var result = await appApiProvider.loadConnections(existingUsers);
    checkExpiredSession(result);
    return result;
  }

  Future<QueryResult> getLocations() async {
    return await appApiProvider.getLocations();
  }

  Future<QueryResult> createUser(
      String name, int location, String firebaseId, String phoneNumber) async {
    var result = await appApiProvider.createUser(
        name, location, firebaseId, phoneNumber);
    checkExpiredSession(result);
    return result;
  }

  Future<QueryResult> createLocation(String city) async {
    var result = await appApiProvider.createLocation(city);
    checkExpiredSession(result);
    return result;
  }

  Future<QueryResult> checkContacts(List<String> phoneContacts) async {
    var result = await appApiProvider.checkContacts(phoneContacts);
    checkExpiredSession(result);
    return result;
  }

  Future<QueryResult> deleteConnection(int connectionId) async {
    var result = await appApiProvider.deleteConnection(connectionId);
    checkExpiredSession(result);
    return result;
  }

  Future<QueryResult> createReview(
      String userId, int userTagId, int stars, String text) async {
    var result =
        await appApiProvider.createReview(userId, userTagId, stars, text);
    checkExpiredSession(result);
    return result;
  }

  Future unsubscribeFromPushNotifications() async {
    var channels = await getStringOfChannelIds();
    return
        await appApiProvider.unsubscribeFromPushNotifications(channels);
  }

  Future<String> uploadPic(File image) async {
    return await appApiProvider.uploadPic(image);
  }

  Future<bool> sendMessage(String channelId, PnGCM pnGCM) async {
    return await appApiProvider.sendMessage(channelId, pnGCM);
  }

  Future<http.Response> getHistoryMessages(
      String channelName, int historyStart, int numberOfMessagesToFetch) async {
    return await appApiProvider.getHistoryMessages(
        channelName, historyStart, numberOfMessagesToFetch);
  }

  Future<http.Response> subscribeToChannel(
      String channelName, String currentUserId, String timestamp) async {
    return await appApiProvider.subscribeToChannel(
        channelName, currentUserId, timestamp);
  }

  Future<List<PubNubConversation>> getPubNubConversations() async {
    var conversationsList = await getListOfIdsFromBackend();
    var channels = await getStringOfChannelIds();
    var response = await appApiProvider.getPubNubConversations(channels);

    if (response.statusCode == 200) {
      BatchHistoryResponse batchHistoryResponse =
          BatchHistoryResponse.fromJson(convert.jsonDecode(response.body));

      var pubNubConversationsList = batchHistoryResponse.conversations;

      for (var pubNubConversation in pubNubConversationsList) {
        var conversation = conversationsList
            .firstWhere((con) => con.id == pubNubConversation.id);
        pubNubConversation.user1 = conversation.user1;
        pubNubConversation.user2 = conversation.user2;
      }
      return pubNubConversationsList;
    } else {
      print("Request failed with status: ${response.statusCode}.");
      return List<PubNubConversation>();
    }
  }

  void dispose() {
    appApiProvider.dispose();
  }

  Future<QueryResult> createRecommends(
      int cardId, String userAskId, String userSendId, String userRecId) async {
    var result = await appApiProvider.createRecommend(
        cardId, userAskId, userSendId, userRecId);
    checkExpiredSession(result);
    return result;
  }

  void checkExpiredSession(QueryResult result) {
    if (result.errors != null &&
        result.errors.isNotEmpty &&
        result.errors[0].extensions != null &&
        result.errors[0].extensions["exception"] != null &&
        result.errors[0].extensions["exception"]["errorInfo"] != null &&
        result.errors[0].extensions["exception"]["errorInfo"]['code'] &&
        result.errors[0].extensions["exception"]["errorInfo"]["code"] ==
            "auth/id-token-expired") {
      clearUserSession(true);
    }
  }

  Future clearUserSession(bool showExpiredSessionMessage) async {
    await FirebaseAuth.instance.signOut().then((_) async {
      await unsubscribeFromPushNotifications();
      SharedPreferencesHelper.clear().then((_) {
        logout(showExpiredSessionMessage);
      });
    });
  }
}
