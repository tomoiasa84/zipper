import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class RecommendFriendBloc {
  Repository _repository = Repository();

  Future<QueryResult> getUsers() async {
    return _repository.getUsers();
  }

}
