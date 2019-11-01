import 'dart:io';

import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ProfileSettingsBloc {
  Repository _repository = Repository();

  Future<QueryResult> updateUser(String id, String firebaseId, String name, int location,
      bool isActive, String phoneNumber, String profilePicUrl, String description) async {
    return _repository.updateUser(
        id, firebaseId, name, location, isActive, phoneNumber, profilePicUrl, description);
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

  Future<String> uploadPic(File image) async {
    return await _repository.uploadPic(image);
  }
}
