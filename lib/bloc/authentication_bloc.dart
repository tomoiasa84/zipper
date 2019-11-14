import 'package:contractor_search/model/location.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/global_variables.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AuthenticationBloc {
  Future<List<LocationModel>> getLocations() async {
    QueryResult data = await Repository().getLocations();
    List<LocationModel> list = [];
    if (data.data == null) {
      return list;
    }

    final List<Map<String, dynamic>> locations =
        data.data['get_locations'].cast<Map<String, dynamic>>();

    locations.forEach((location) => list.add(LocationModel.fromJson(location)));
    return list;
  }

  Future saveAccessToken(String accessToken) async {
    await SharedPreferencesHelper.saveAccessToken(accessToken);
  }

  Future<QueryResult> getUserFromContact(String phoneNumber) async {
    return Repository().getUserFromContact(phoneNumber);
  }

  Future<QueryResult> createUser(
      String name, int location, String firebaseId, String phoneNumber) async {
    return Repository()
        .createUser(name, location, firebaseId, phoneNumber);
  }

  Future<QueryResult> updateUser(String id, String firebaseId, String name,
      int location, bool isActive, String phoneNumber) async {
    return Repository().updateUser(
        id, firebaseId, name, location, isActive, phoneNumber, "", "");
  }

  Future<QueryResult> createLocation(String city) async {
    return Repository().createLocation(city);
  }

  Future saveCurrentUserId(String userId) async {
    await SharedPreferencesHelper.saveCurrentUserId(userId);
  }

  Future saveCurrentUserName(String userName) async {
    await SharedPreferencesHelper.saveCurrentUserName(userName);
  }
}
