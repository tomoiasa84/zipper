import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class UsersBloc {
  Repository _repository = Repository();

  getContacts() async {
    return await _repository.getContacts();
  }

  Future<QueryResult> getCurrentUser() async {
    String userId = await getCurrentUserId();

    return _repository.getUserById(userId);
  }
}
