import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rxdart/rxdart.dart';

class MyProfileBloc {
  final _getUserByIdWithMainInfoFetcher = PublishSubject<QueryResult>();
  final _deleteCardFetcher = PublishSubject<QueryResult>();

  Observable<QueryResult> get getUserByIdWithMainInfoObservable =>
      _getUserByIdWithMainInfoFetcher.stream;

  Observable<QueryResult> get deleteCardObservable => _deleteCardFetcher.stream;

  Future<String> getCurrentUserId() async {
    return await SharedPreferencesHelper.getCurrentUserId();
  }

  getUserByIdWithMainInfo() async {
    String userId = await getCurrentUserId();

    QueryResult result = await Repository().getUserByIdWithMainInfo(userId);
    if (!_getUserByIdWithMainInfoFetcher.isClosed) {
      _getUserByIdWithMainInfoFetcher.sink.add(result);
    }
  }

  deleteCard(int cardId) async {
    var result = await Repository().deleteCard(cardId);
    if (!_deleteCardFetcher.isClosed) {
      _deleteCardFetcher.sink.add(result);
    }
  }

  Future clearUserSession() async {
    return await Repository().clearUserSession(false);
  }

  dispose() {
    _getUserByIdWithMainInfoFetcher.close();
    _deleteCardFetcher.close();
  }
}
