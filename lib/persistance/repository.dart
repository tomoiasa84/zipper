import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/model/conversation_model.dart';
import 'package:contractor_search/model/location.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'api_provider.dart';

class Repository{
  ApiProvider appApiProvider = ApiProvider();

  getContacts() async {
    return ContactsService.getContacts();
  }


  Future<QueryResult> getUserById(String userId) async {
    return await appApiProvider.getUserById(userId);
  }

  Future<QueryResult> deleteCard(int cardId) async {
    return await appApiProvider.deleteCard(cardId);
  }

  Future<QueryResult> getTags() async {
    return await appApiProvider.getTags();
  }

  Future<QueryResult> createCard( String postedBy, int searchFor, String details) async {
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

  Future<PubNubConversation> createConversation(User user) async {
    String currentUserId = await getCurrentUserId();
    QueryResult result = await appApiProvider.createConversation(user, currentUserId);

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

  Future<QueryResult> getCards() async {
    return await appApiProvider.getCards();
  }

  Future<QueryResult> updateUser(String name, int location, String id,
      String phoneNumber, bool isActive, String description) async {
    return await appApiProvider.updateUser(name, location, id, phoneNumber, isActive, description);
  }

  Future<QueryResult> createUserTag(String userId, int tagId) async {
    return await appApiProvider.createUserTag(userId, tagId);
  }

  Future<QueryResult> updateMainUserTag(int userTagId, bool defaultFlag) async {
    return await appApiProvider.updateMainUserTag(userTagId, defaultFlag);
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

  Future<QueryResult> getLocations() async {
    return await appApiProvider.getLocations();
  }

  Future<QueryResult> createUser( String name, int location, String firebaseId, String phoneNumber) async {
    return await appApiProvider.createUser(name, location, firebaseId, phoneNumber);
  }

  Future<QueryResult> createLocation(String city) async {
    return await appApiProvider.createLocation(city);
  }

  Future<QueryResult> checkContacts(List<String> phoneContacts) async{
    return await appApiProvider.checkContacts(phoneContacts);
  }
  Future<QueryResult>  createReview(String userId, int userTagId, int stars, String text) async{
    return await appApiProvider.createReview(userId, userTagId, stars, text);
  }
  Future<QueryResult>  createRecommends(int cardId, String userAskId, String userSendId, String userRecId) async{
    return await appApiProvider.createRecommend(cardId, userAskId, userSendId, userRecId);
  }
}