import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ProfileSettingsBloc {
  Repository _repository = Repository();

  Future<QueryResult> updateUser(String name, int location, String id,
      String phoneNumber, bool isActive, String description) async {
    return _repository.updateUser(
        name, location, id, phoneNumber, isActive, description);
  }

  Future<QueryResult> createUserTag(String userId, int tagId) async {
    return _repository.createUserTag(userId, tagId);
  }

  Future<QueryResult> updateMainUserTag(int userTagId) async {
    return _repository.updateMainUserTag(userTagId);
  }

  Future<QueryResult> deleteUserTag(int userTagId) async {
    return _repository.deleteUserTag(userTagId);
  }

  Future<QueryResult> getTags() async {
    return _repository.getTags();
  }
}
