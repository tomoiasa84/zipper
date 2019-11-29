import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rxdart/rxdart.dart';

class SelectContactBloc {
  final _createConversationFetcher = PublishSubject<PubNubConversation>();
  final _getCurrentUserFetcher = PublishSubject<QueryResult>();

  Observable<PubNubConversation> get createConversationObservable =>
      _createConversationFetcher.stream;

  Observable<QueryResult> get getCurrentUserObservable =>
      _getCurrentUserFetcher.stream;

  createConversation(User user) async {
    PubNubConversation result = await Repository().createConversation(user);
    if (!_createConversationFetcher.isClosed) {
      _createConversationFetcher.sink.add(result);
    }
  }

  getCurrentUser() async {
    String userId = await getCurrentUserId();
    QueryResult result = await Repository().getUserByIdWithConnections(userId);
    if (!_getCurrentUserFetcher.isClosed) {
      _getCurrentUserFetcher.sink.add(result);
    }
  }

  getCurrentUserWithActiveConnections() async {
    String userId = await getCurrentUserId();
    QueryResult result = await Repository().getUserByIdWithActiveConnections(userId);
    if (!_getCurrentUserFetcher.isClosed) {
      _getCurrentUserFetcher.sink.add(result);
    }
  }

  dispose() {
    _createConversationFetcher.close();
    _getCurrentUserFetcher.close();
  }
}
