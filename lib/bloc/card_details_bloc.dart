
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CardDetailsBloc {

  Repository _repository = Repository();

  Future<QueryResult> getCardById(int cardId) async {
    return _repository.getCardById(cardId);
  }

  Future<PubNubConversation> createConversation(User user) async {
    return await _repository.createConversation(user);
  }
}
