
import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CardDetailsBloc {

  Repository _repository = Repository();

  Future<QueryResult> getCardById(int cardId) async {
    return _repository.getCardById(cardId);
  }
}
