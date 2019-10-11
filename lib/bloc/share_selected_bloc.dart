import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ShareSelectedBloc {
  Repository _repository = Repository();

  Future<QueryResult> loadContacts(List<String> phoneContacts) async {
    return _repository.loadContacts(phoneContacts);
  }

  Future<QueryResult> loadConnections(List<String> existingUsers) async {
    return _repository.loadConnections(existingUsers);
  }
}
