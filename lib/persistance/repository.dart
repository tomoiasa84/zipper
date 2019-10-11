import 'dart:convert' as convert;
import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/model/conversation_model.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/BatchHistoryResponse.dart';
import 'package:contractor_search/models/PnGCM.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;

import 'api_provider.dart';

class Repository {
  ApiProvider appApiProvider = ApiProvider();

  getContacts() async {
    return ContactsService.getContacts();
  }

  Future<QueryResult> getUserById(String userId) async {
    return await appApiProvider.getUserById(userId);
  }

  Future<QueryResult> getCardById(int cardId) async {
    return await appApiProvider.getCardById(cardId);
  }

  Future<QueryResult> deleteCard(int cardId) async {
    return await appApiProvider.deleteCard(cardId);
  }

  Future<QueryResult> getTags() async {
    return await appApiProvider.getTags();
  }

  Future<QueryResult> createCard(
      String postedBy, int searchFor, String details) async {
    return await appApiProvider.createCard(postedBy, searchFor, details);
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
    return await appApiProvider.createConnection(currentUserId, targetUserId);
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
    return await appApiProvider.getListOfIdsFromBackend(currentUserId);
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
    return await appApiProvider.getCards();
  }

  Future<QueryResult> updateUser(
      String name,
      int location,
      String id,
      String phoneNumber,
      bool isActive,
      String description,
      String profilePicUrl) async {
    return await appApiProvider.updateUser(
        name, location, id, phoneNumber, isActive, description, profilePicUrl);
  }

  Future<QueryResult> createUserTag(String userId, int tagId) async {
    return await appApiProvider.createUserTag(userId, tagId);
  }

  Future<QueryResult> updateMainUserTag(int userTagId) async {
    return await appApiProvider.updateMainUserTag(userTagId);
  }

  Future<QueryResult> deleteUserTag(int userTagId) async {
    return await appApiProvider.deleteUserTag(userTagId);
  }

  Future<QueryResult> getUsers() async {
    return await appApiProvider.getUsers();
  }

  Future<QueryResult> loadContacts(List<String> phoneContacts) async {
    return await appApiProvider.loadContacts(phoneContacts);
  }

  Future<QueryResult> loadConnections(List<String> existingUsers) async {
    return await appApiProvider.loadConnections(existingUsers);
  }

  Future<QueryResult> getLocations() async {
    return await appApiProvider.getLocations();
  }

  Future<QueryResult> createUser(
      String name, int location, String firebaseId, String phoneNumber) async {
    return await appApiProvider.createUser(
        name, location, firebaseId, phoneNumber);
  }

  Future<QueryResult> createLocation(String city) async {
    return await appApiProvider.createLocation(city);
  }

  Future<QueryResult> checkContacts(List<String> phoneContacts) async {
    return await appApiProvider.checkContacts(phoneContacts);
  }

  Future<QueryResult> deleteConnection(int connectionId) async {
    return await appApiProvider.deleteConnection(connectionId);
  }

  Future<QueryResult> createReview(
      String userId, int userTagId, int stars, String text) async {
    return await appApiProvider.createReview(userId, userTagId, stars, text);
  }

  void subscribeToPushNotifications(String channelId) async {
    appApiProvider.subscribeToPushNotifications(channelId);
  }

  Future unsubscribeFromPushNotifications() async {
    var channels = await getStringOfChannelIds();
    return await appApiProvider.unsubscribeFromPushNotifications(channels);
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
    return await appApiProvider.createRecommend(
        cardId, userAskId, userSendId, userRecId);
  }
}
