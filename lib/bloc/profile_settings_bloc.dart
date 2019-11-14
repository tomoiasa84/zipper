import 'dart:io';

import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/global_variables.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ProfileSettingsBloc {

  Future<QueryResult> updateUser(String id, String firebaseId, String name, int location,
      bool isActive, String phoneNumber, String profilePicUrl, String description) async {
    return Repository().updateUser(
        id, firebaseId, name, location, isActive, phoneNumber, profilePicUrl, description);
  }

  Future<QueryResult> createUserTag(String userId, int tagId) async {
    return Repository().createUserTag(userId, tagId);
  }

  Future<QueryResult> updateMainUserTag(int userTagId) async {
    return Repository().updateMainUserTag(userTagId);
  }

  Future<QueryResult> deleteUserTag(int userTagId) async {
    return Repository().deleteUserTag(userTagId);
  }

  Future<QueryResult> getTags() async {
    return Repository().getTags();
  }

  Future<String> uploadPic(File image) async {
    return await Repository().uploadPic(image);
  }
}
