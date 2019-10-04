import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class UserDetailsBloc {
  Repository _repository = Repository();

  Future<QueryResult> getCurrentUser(String userId) async {
    return await _repository.getUserById(userId);
  }

  Future<PubNubConversation> createConversation(User user) async {
    return await _repository.createConversation(user);
  }

  Future createConnection(String currentUserId, String targetUserId) async {
    return await _repository.createConnection(currentUserId, targetUserId);
  }

  Future<QueryResult> createReview(
      String userId, int userTagId, int stars, String text) async {
    return _repository.createReview(userId, userTagId, stars, text);
  }
}
