import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class UsersBloc {
  Repository _repository = Repository();

  getContacts() async {
    return await _repository.getContacts();
  }

  Future<QueryResult> getUsers() async {
    return _repository.getUsers();
  }
}
