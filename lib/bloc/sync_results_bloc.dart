import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SyncResultsBloc {
  Repository _repository = Repository();

  Future<QueryResult> loadConnections(List<String> existingUsers) async {
    return _repository.loadConnections(existingUsers);
  }
}
