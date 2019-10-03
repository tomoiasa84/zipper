import 'dart:io';

import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ProfileSettingsBloc {
  Repository _repository = Repository();

  Future<QueryResult> updateUser(String name, int location, String id,
      String phoneNumber, bool isActive, String description, String profilePicUrl) async {
    return _repository.updateUser(
        name, location, id, phoneNumber, isActive, description, profilePicUrl);
  }

  Future<QueryResult> createUserTag(String userId, int tagId) async {
    return _repository.createUserTag(userId, tagId);
  }

  Future<QueryResult> updateMainUserTag(int userTagId, bool defaultFlag) async {
    return _repository.updateMainUserTag(userTagId, defaultFlag);
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
