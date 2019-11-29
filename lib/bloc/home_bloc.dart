import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rxdart/rxdart.dart';

class HomeBloc {
  final _getUserByIdWithCardsConnectionsFetcher = PublishSubject<QueryResult>();

  Observable<QueryResult> get getUserByIdWithCardsConnectionsObservable =>
      _getUserByIdWithCardsConnectionsFetcher.stream;

  getUserByIdWithCardsConnections() async {
    String userId = await getCurrentUserId();

    QueryResult result =
        await Repository().getUserByIdWithCardsConnections(userId);
    if (!_getUserByIdWithCardsConnectionsFetcher.isClosed) {
      _getUserByIdWithCardsConnectionsFetcher.sink.add(result);
    }
  }

  dispose() {
    _getUserByIdWithCardsConnectionsFetcher.close();
  }
}
