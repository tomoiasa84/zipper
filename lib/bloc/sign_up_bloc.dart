import 'package:contractor_search/model/location.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SignUpBloc {
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

  Future<QueryResult> getUsers() async {
    return _repository.getUsers();
  }

  Future<QueryResult> createUser(
      String name, int location, String firebaseId, String phoneNumber) async {
    return _repository.createUser(name, location, firebaseId, phoneNumber);
  }

  Future<QueryResult> updateUser(String name, int location, String id,
      String phoneNumber, bool isActive) async {
    return _repository.updateUser(
        name, location, id, phoneNumber, isActive, "", null);
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
