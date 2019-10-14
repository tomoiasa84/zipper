import 'package:contractor_search/model/location.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class LoginBloc {
  Repository _repository = Repository();

  Future saveAccessToken(String accessToken) async {
    await SharedPreferencesHelper.saveAccessToken(accessToken);
  }

  Future<QueryResult> getUsers() async {
    return _repository.getUsers();
  }

  Future saveCurrentUserId(String userId) async {
    await SharedPreferencesHelper.saveCurrentUserId(userId);
  }

  Future saveCurrentUserName(String userName) async {
    await SharedPreferencesHelper.saveCurrentUserName(userName);
  }
}
