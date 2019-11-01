import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AccountBloc {
  Repository _repository = Repository();

  Future<String> getCurrentUserId() async {
    return await SharedPreferencesHelper.getCurrentUserId();
  }

  Future<QueryResult> getUserByIdWithMainInfo() async {
    String userId = await getCurrentUserId();

    return _repository.getUserByIdWithMainInfo(userId);
  }

  Future<QueryResult> deleteCard(int cardId) async {
    return _repository.deleteCard(cardId);
  }

  Future clearUserSession() async {
   return await _repository.clearUserSession(false);
  }
}
