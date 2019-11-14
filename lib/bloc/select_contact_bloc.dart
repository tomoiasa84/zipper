import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/global_variables.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SelectContactBloc {

  Future<PubNubConversation> createConversation(User user) async {
    return await Repository().createConversation(user);
  }

  Future<QueryResult> getCurrentUser() async {
    String userId = await getCurrentUserId();
    return Repository().getUserByIdWithConnections(userId);
  }
}
