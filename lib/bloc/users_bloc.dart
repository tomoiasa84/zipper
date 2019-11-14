import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/global_variables.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class UsersBloc {

  getContacts() async {
    return await Repository().getContacts();
  }

  Future<QueryResult> getCurrentUserWithConnections() async {
    String userId = await getCurrentUserId();
    return Repository().getUserByIdWithConnections(userId);
  }
}
