import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/global_variables.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ShareSelectedBloc {

  Future<QueryResult> loadContacts(List<String> phoneContacts) async {
    return Repository().loadContacts(phoneContacts);
  }

  Future<QueryResult> loadConnections(List<String> existingUsers) async {
    return Repository().loadConnections(existingUsers);
  }
}
