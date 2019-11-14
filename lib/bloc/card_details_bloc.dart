
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/global_variables.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CardDetailsBloc {

  Future<QueryResult> getCardById(int cardId) async {
    return Repository().getCardById(cardId);
  }

  Future<PubNubConversation> createConversation(User user) async {
    return await Repository().createConversation(user);
  }
}
