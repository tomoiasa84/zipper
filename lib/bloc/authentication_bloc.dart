import 'package:contractor_search/model/location.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rxdart/rxdart.dart';

class AuthenticationBloc {
  final _getLocationsFetcher = PublishSubject<List<LocationModel>>();
  final _getUserFromContactFetcher = PublishSubject<QueryResult>();
  final _createUserFetcher = PublishSubject<QueryResult>();
  final _updateUserFetcher = PublishSubject<QueryResult>();
  final _createLocationFetcher = PublishSubject<QueryResult>();

  Observable<List<LocationModel>> get getLocationsObservable =>
      _getLocationsFetcher.stream;

  Observable<QueryResult> get getUserFromContactObservable =>
      _getUserFromContactFetcher.stream;

  Observable<QueryResult> get createUserObservable => _createUserFetcher.stream;

  Observable<QueryResult> get updateUserObservable => _updateUserFetcher.stream;

  Observable<QueryResult> get createLocationObservable =>
      _createLocationFetcher.stream;

  getLocations() async {
    QueryResult data = await Repository().getLocations();
    List<LocationModel> list = [];
    if (data.data == null) {
      return list;
    }

    final List<Map<String, dynamic>> locations =
        data.data['get_locations'].cast<Map<String, dynamic>>();

    locations.forEach((location) => list.add(LocationModel.fromJson(location)));
    if (!_getLocationsFetcher.isClosed) {
      _getLocationsFetcher.sink.add(list);
    }
  }

  Future saveAccessToken(String accessToken) async {
    await SharedPreferencesHelper.saveAccessToken(accessToken);
  }

  getUserFromContact(String phoneNumber) async {
    QueryResult result = await Repository().getUserFromContact(phoneNumber);
    if (!_getUserFromContactFetcher.isClosed) {
      _getUserFromContactFetcher.sink.add(result);
    }
  }

  createUser(
      String name, int location, String firebaseId, String phoneNumber) async {
    QueryResult result =
        await Repository().createUser(name, location, firebaseId, phoneNumber);
    if (!_createUserFetcher.isClosed) {
      _createUserFetcher.sink.add(result);
    }
  }

  updateUser(String id, String firebaseId, String name, int location,
      bool isActive, String phoneNumber) async {
    QueryResult result = await Repository().updateUser(
        id, firebaseId, name, location, isActive, phoneNumber, "", "");
    if (!_updateUserFetcher.isClosed) {
      _updateUserFetcher.sink.add(result);
    }
  }

  createLocation(String city) async {
    QueryResult result = await Repository().createLocation(city);
    if (!_createLocationFetcher.isClosed) {
      _createLocationFetcher.sink.add(result);
    }
  }

  Future saveCurrentUserId(String userId) async {
    await SharedPreferencesHelper.saveCurrentUserId(userId);
  }

  Future saveCurrentUserName(String userName) async {
    await SharedPreferencesHelper.saveCurrentUserName(userName);
  }

  dispose() {
    _getLocationsFetcher.close();
    _getUserFromContactFetcher.close();
    _createUserFetcher.close();
    _updateUserFetcher.close();
    _createLocationFetcher.close();
  }
}
