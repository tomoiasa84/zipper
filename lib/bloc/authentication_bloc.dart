import 'package:contractor_search/model/location.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AuthenticationBloc {
  Repository _repository = Repository();

  Future<List<LocationModel>> getLocations() async {
    QueryResult data = await _repository.getLocations();

    final List<Map<String, dynamic>> locations =
        data.data['get_locations'].cast<Map<String, dynamic>>();
    List<LocationModel> list = [];
    locations.forEach((location) => list.add(LocationModel.fromJson(location)));
    return list;
  }

  Future saveAccessToken(String accessToken) async {
    await SharedPreferencesHelper.saveAccessToken(accessToken);
  }

  Future<QueryResult> getUserFromContact(String phoneNumber) async {
    return _repository.getUserFromContact(phoneNumber);
  }

  Future<QueryResult> createUser(
      String name, int location, String firebaseId, String phoneNumber) async {
    return _repository.createUser(name, location, firebaseId, phoneNumber);
  }

  Future<QueryResult> updateUser(String id, String firebaseId, String name, int location,
      bool isActive, String phoneNumber) async {
    return _repository.updateUser(
        id, firebaseId, name, location, isActive, phoneNumber, "", "");
  }

  Future<QueryResult> createLocation(String city) async {
    return _repository.createLocation(city);
  }

  Future saveCurrentUserId(String userId) async {
    await SharedPreferencesHelper.saveCurrentUserId(userId);
  }

  Future saveCurrentUserName(String userName) async {
    await SharedPreferencesHelper.saveCurrentUserName(userName);
  }
}
