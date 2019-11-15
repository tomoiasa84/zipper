import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PnGCM.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rxdart/rxdart.dart';

class RecommendFriendBloc {
  final _createRecommendFetcher = PublishSubject<QueryResult>();
  final _createConversationFetcher = PublishSubject<PubNubConversation>();
  final _sendMessageFetcher = PublishSubject<bool>();
  final _getCurrentUserWithConnectionsFetcher = PublishSubject<QueryResult>();

  Observable<QueryResult> get createRecommendObservable =>
      _createRecommendFetcher.stream;

  Observable<PubNubConversation> get createConversationObservable =>
      _createConversationFetcher.stream;

  Observable<bool> get sendMessageObservable => _sendMessageFetcher.stream;

  Observable<QueryResult> get getCurrentUserWithConnectionsObservable =>
      _getCurrentUserWithConnectionsFetcher.stream;

  createRecommend(int cardId, String userAskId, String userRecId) async {
    String userSendId = await getCurrentUserId();
    QueryResult result = await Repository()
        .createRecommends(cardId, userAskId, userSendId, userRecId);
    if (!_createRecommendFetcher.isClosed) {
      _createRecommendFetcher.sink.add(result);
    }
  }

  createConversation(User user) async {
    PubNubConversation result = await Repository().createConversation(user);
    if (!_createConversationFetcher.isClosed) {
      _createConversationFetcher.sink.add(result);
    }
  }

  sendMessage(String channelId, PnGCM pnGCM) async {
    bool result = await Repository().sendMessage(channelId, pnGCM);
    if (!_sendMessageFetcher.isClosed) {
      _sendMessageFetcher.sink.add(result);
    }
  }

  getCurrentUserWithConnections() async {
    String userId = await getCurrentUserId();

    QueryResult result = await Repository().getUserByIdWithConnections(userId);
    if (!_getCurrentUserWithConnectionsFetcher.isClosed) {
      _getCurrentUserWithConnectionsFetcher.sink.add(result);
    }
  }

  dispose() {
    _createRecommendFetcher.close();
    _createConversationFetcher.close();
    _sendMessageFetcher.close();
    _getCurrentUserWithConnectionsFetcher.close();
  }
}
