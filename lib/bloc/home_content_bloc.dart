import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/custom_auth_link.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/global_variables.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class HomeContentBloc {


  Future<QueryResult> getUserByIdWithCardsConnections() async {
    String userId = await getCurrentUserId();

    return Repository().getUserByIdWithCardsConnections(userId);
  }
}
