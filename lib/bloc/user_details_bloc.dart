import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class UserDetailsBloc {
  Repository _repository = Repository();

  Future<QueryResult> getUserByIdWithMainInfo(String userId) async {
    return await _repository.getUserByIdWithMainInfo(userId);
  }

  Future<QueryResult> getUserByIdWithConnections(String userId) async {
    return await _repository.getUserByIdWithConnections(userId);
  }

  Future<PubNubConversation> createConversation(User user) async {
    return await _repository.createConversation(user);
  }

  Future createConnection(String currentUserId, String targetUserId) async {
    return await _repository.createConnection(currentUserId, targetUserId);
  }

  Future deleteConnection(int connectionId) async {
    return await _repository.deleteConnection(connectionId);
  }

  Future<QueryResult> createReview(
      String userId, int userTagId, int stars, String text) async {
    return _repository.createReview(
        userId, userTagId, stars, removeMultilineCharacters(text));
  }

  Future<dynamic> addContact(String displayName, String phoneNumber) {
    Contact contact = Contact();
    contact.familyName = displayName;
    contact.phones = [Item(label: "mobile", value: phoneNumber)];
    return ContactsService.addContact(contact);
  }
}
