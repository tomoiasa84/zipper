import 'dart:io';

import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rxdart/rxdart.dart';

class MyProfileSettingsBloc {
  final _updateUserFetcher = PublishSubject<QueryResult>();
  final _createUserTagFetcher = PublishSubject<QueryResult>();
  final _updateMainUserTagFetcher = PublishSubject<QueryResult>();
  final _deleteUserTagFetcher = PublishSubject<QueryResult>();
  final _getTagsFetcher = PublishSubject<QueryResult>();

  Observable<QueryResult> get updateUserObservable => _updateUserFetcher.stream;

  Observable<QueryResult> get createUserTagObservable =>
      _createUserTagFetcher.stream;

  Observable<QueryResult> get updateMainUserTagObservable =>
      _updateMainUserTagFetcher.stream;

  Observable<QueryResult> get deleteUserTagObservable =>
      _deleteUserTagFetcher.stream;

  Observable<QueryResult> get getTagsObservable => _getTagsFetcher.stream;

  updateUser(
      String id,
      String firebaseId,
      String name,
      int location,
      bool isActive,
      String phoneNumber,
      String profilePicUrl,
      String description) async {
    QueryResult result = await Repository().updateUser(id, firebaseId, name,
        location, isActive, phoneNumber, profilePicUrl, description);
    if (!_updateUserFetcher.isClosed) {
      _updateUserFetcher.sink.add(result);
    }
  }

  createUserTag(String userId, int tagId) async {
    QueryResult result = await Repository().createUserTag(userId, tagId);
    if (!_createUserTagFetcher.isClosed) {
      _createUserTagFetcher.sink.add(result);
    }
  }

  updateMainUserTag(int userTagId) async {
    QueryResult result = await Repository().updateMainUserTag(userTagId);
    if (!_updateMainUserTagFetcher.isClosed) {
      _updateMainUserTagFetcher.sink.add(result);
    }
  }

  deleteUserTag(int userTagId) async {
    QueryResult result = await Repository().deleteUserTag(userTagId);
    if (!_deleteUserTagFetcher.isClosed) {
      _deleteUserTagFetcher.sink.add(result);
    }
  }

  getTags() async {
    QueryResult result = await Repository().getTags();
    if (!_getTagsFetcher.isClosed) {
      _getTagsFetcher.sink.add(result);
    }
  }

  Future<String> uploadPic(File image) async {
    return Repository().uploadPic(image);
  }

  dispose() {
    _updateUserFetcher.close();
    _createUserTagFetcher.close();
    _updateMainUserTagFetcher.close();
    _deleteUserTagFetcher.close();
    _getTagsFetcher.close();
  }
}
