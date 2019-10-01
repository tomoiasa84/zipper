import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SmsCodeVerificationBloc {
  Repository _repository = Repository();

  Future<QueryResult> getLocations() async {
    return _repository.getLocations();
  }

  Future<QueryResult> createUser(
      String name, int location, String firebaseId, String phoneNumber) async {
    return _repository.createUser(name, location, firebaseId, phoneNumber);
  }

  Future<QueryResult> updateUser(String name, int location, String id,
      String phoneNumber, bool isActive) async {
    return _repository.updateUser(
        name, location, id, phoneNumber, isActive, "");
  }

  Future<QueryResult> createLocation(String city) async {
    return _repository.createLocation(city);
  }

  Future<QueryResult> getUsers() async {
    return _repository.getUsers();
  }

  Future saveAccessToken(String accessToken) async {
    await SharedPreferencesHelper.saveAccessToken(accessToken);
  }

  Future saveCurrentUserId(String userId) async {
    await SharedPreferencesHelper.saveCurrentUserId(userId);
  }

  Future saveCurrentUserName(String userName) async {
    await SharedPreferencesHelper.saveCurrentUserName(userName);
  }
}
