import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/global_variables.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class UserDetailsBloc {

  Future<QueryResult> getUserByIdWithMainInfo(String userId) async {
    return await Repository().getUserByIdWithMainInfo(userId);
  }

  Future<QueryResult> getUserByIdWithConnections(String userId) async {
    return await Repository().getUserByIdWithConnections(userId);
  }

  Future<PubNubConversation> createConversation(User user) async {
    return await Repository().createConversation(user);
  }

  Future<QueryResult> createConnection(String currentUserId, String targetUserId) async {
    return await Repository().createConnection(currentUserId, targetUserId);
  }

  Future<QueryResult> deleteConnection(int connectionId) async {
    return await Repository().deleteConnection(connectionId);
  }

  Future<QueryResult> createReview(
      String userId, int userTagId, int stars, String text) async {
    return Repository().createReview(
        userId, userTagId, stars, removeMultilineCharacters(text));
  }

  Future<dynamic> addContact(String displayName, String phoneNumber) {
    Contact contact = Contact();
    contact.familyName = displayName;
    contact.phones = [Item(label: "mobile", value: phoneNumber)];
    return ContactsService.addContact(contact);
  }
}
