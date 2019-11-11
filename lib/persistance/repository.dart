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
    return ContactsService.getContacts(
        photoHighResolution: false,
        orderByGivenName: false,
        withThumbnails: false);
  }

  Future<QueryResult> getUserByIdWithPhoneNumber(String userId) async {
    var result = await appApiProvider.getUserByIdWithPhoneNumber(userId);
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> getUserFromContact(String phoneNumber) async {
    var result = await appApiProvider.getUserFromContact(phoneNumber);
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> getUserByIdWithConnections(String userId) async {
    var result = await appApiProvider.getUserByIdWithConnections(userId);
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> getUserByIdWithCardsConnections(String userId) async {
    var result = await appApiProvider.getUserByIdWithCardsConnections(userId);
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> getCurrentUserWithCards(String userId) async {
    var result = await appApiProvider.getCurrentUserWithCards(userId);
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> getUserNameIdPhoneNumberProfilePic(String userId) async {
    var result =
        await appApiProvider.getUserNameIdPhoneNumberProfilePic(userId);
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> getUserById(String userId) async {
    var result = await appApiProvider.getUserById(userId);
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> getCurrentUserWithFirebaseId(String userId) async {
    var result = await appApiProvider.getCurrentUserWithFirebaseId(userId);
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> getUserByIdWithMainInfo(String userId) async {
    var result = await appApiProvider.getUserByIdWithMainInfo(userId);
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> getCardById(int cardId) async {
    var result = await appApiProvider.getCardById(cardId);
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> deleteCard(int cardId) async {
    var result = await appApiProvider.deleteCard(cardId);
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> getTags() async {
    var result = await appApiProvider.getTags();
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> createCard(
      String postedBy, int searchFor, String details) async {
    var result = await appApiProvider.createCard(postedBy, searchFor, details);
    checkTokenError(result);
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
    checkTokenError(result);
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

  Future<List<ConversationModel>> getListOfConversationIdsFromBackend() async {
    String currentUserId = await getCurrentUserId();
    var result =
        await appApiProvider.getListOfChannelIdsFromBackend(currentUserId);
    checkTokenError(result);
    User currentUser = User.fromJson(result.data['get_user']);
    return currentUser.conversations;
  }

  Future<String> getStringOfChannelIds() async {
    var listOfConversations = await getListOfConversationIdsFromBackend();

    String channelIds = "";

    for (var item in listOfConversations) {
      channelIds = channelIds + item.id.toString() + ",";
    }

    return channelIds;
  }

  Future<QueryResult> getCards() async {
    var result = await appApiProvider.getCards();
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> updateUser(
      String id,
      String firebaseId,
      String name,
      int location,
      bool isActive,
      String phoneNumber,
      String profilePicUrl,
      String description) async {
    var result = await appApiProvider.updateUser(id, firebaseId, name, location,
        isActive, phoneNumber, profilePicUrl, description);
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> updateDeviceToken(
      String id, String deviceToken, String firebaseId) async {
    var result =
        await appApiProvider.updateDeviceToken(id, deviceToken, firebaseId);
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> createUserTag(String userId, int tagId) async {
    var result = await appApiProvider.createUserTag(userId, tagId);
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> updateMainUserTag(int userTagId) async {
    var result = await appApiProvider.updateMainUserTag(userTagId);
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> deleteUserTag(int userTagId) async {
    var result = await appApiProvider.deleteUserTag(userTagId);
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> loadContacts(List<String> phoneContacts) async {
    var result = await appApiProvider.loadContacts(phoneContacts);
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> loadConnections(List<String> existingUsers) async {
    var result = await appApiProvider.loadConnections(existingUsers);
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> getLocations() async {
    return await appApiProvider.getLocations();
  }

  Future<QueryResult> createUser(
      String name, int location, String firebaseId, String phoneNumber) async {
    var result = await appApiProvider.createUser(
        name, location, firebaseId, phoneNumber);
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> createLocation(String city) async {
    var result = await appApiProvider.createLocation(city);
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> checkContacts(List<String> phoneContacts) async {
    var result = await appApiProvider.checkContacts(phoneContacts);
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> deleteConnection(int connectionId) async {
    var result = await appApiProvider.deleteConnection(connectionId);
    checkTokenError(result);
    return result;
  }

  Future<QueryResult> createReview(
      String userId, int userTagId, int stars, String text) async {
    var result =
        await appApiProvider.createReview(userId, userTagId, stars, text);
    checkTokenError(result);
    return result;
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
    var conversationsList = await getListOfConversationIdsFromBackend();

    String channels = "";

    for (var item in conversationsList) {
      channels = channels + item.id.toString() + ",";
    }

    return appApiProvider.getPubNubConversations(channels).then((response) {
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
    }).catchError((error) {});
  }

  void dispose() {
    appApiProvider.dispose();
  }

  Future<QueryResult> createRecommends(
      int cardId, String userAskId, String userSendId, String userRecId) async {
    var result = await appApiProvider.createRecommend(
        cardId, userAskId, userSendId, userRecId);
    checkTokenError(result);
    return result;
  }

  void checkTokenError(QueryResult result) {
    if ((result.errors != null &&
            result.errors.isNotEmpty &&
            result.errors[0].extensions != null &&
            result.errors[0].extensions["exception"] != null &&
            result.errors[0].extensions["exception"]["errorInfo"] != null &&
            result.errors[0].extensions["exception"]["errorInfo"]['code'] !=
                null &&
            result.errors[0].extensions["exception"]["errorInfo"]["code"] ==
                "auth/id-token-expired") ||
        (result.errors != null &&
            result.errors.isNotEmpty &&
            result.errors[0].extensions != null &&
            result.errors[0].extensions["exception"] != null &&
            result.errors[0].extensions["exception"]["errorInfo"] != null &&
            result.errors[0].extensions["exception"]["errorInfo"]['code'] !=
                null &&
            result.errors[0].extensions["exception"]["errorInfo"]["code"] ==
                "auth/argument-error")) {
      clearUserSession(true);
    }
  }

  Future clearUserSession(bool showExpiredSessionMessage) async {
    await FirebaseAuth.instance.signOut().then((_) async {
      SharedPreferencesHelper.clear().then((_) {
        logout(showExpiredSessionMessage);
      });
    });
  }
}
