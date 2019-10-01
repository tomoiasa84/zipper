import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class UserDetailsBloc {
  Repository _repository = Repository();

  Future<QueryResult> getCurrentUser(String userId) async {
    return await _repository.getUserById(userId);
  }

  Future<QueryResult> createReview(
      String userId, int userTagId, int stars, String text) async {
    return _repository.createReview(userId, userTagId, stars, text);
  }
}
