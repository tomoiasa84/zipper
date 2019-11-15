import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rxdart/rxdart.dart';

class CardDetailsBloc {
  final _getCardByIdFetcher = PublishSubject<QueryResult>();
  final _createConversationFetcher = PublishSubject<PubNubConversation>();

  Observable<QueryResult> get getCardByIdObservable =>
      _getCardByIdFetcher.stream;

  Observable<PubNubConversation> get createConversationObservable =>
      _createConversationFetcher.stream;

  getCardById(int cardId) async {
    QueryResult result = await Repository().getCardById(cardId);
    if (!_getCardByIdFetcher.isClosed) {
      _getCardByIdFetcher.sink.add(result);
    }
  }

  createConversation(User user) async {
    PubNubConversation result = await Repository().createConversation(user);
    if (!_createConversationFetcher.isClosed) {
      _createConversationFetcher.sink.add(result);
    }
  }

  dispose() {
    _getCardByIdFetcher.close();
    _createConversationFetcher.close();
  }
}
