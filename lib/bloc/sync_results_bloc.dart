import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rxdart/rxdart.dart';

class SyncResultsBloc {
  final _loadConnectionsFetcher = PublishSubject<QueryResult>();

  Observable<QueryResult> get loadConnectionsObservable =>
      _loadConnectionsFetcher.stream;

  loadConnections(List<String> existingUsers) async {
    QueryResult result = await Repository().loadConnections(existingUsers);
    if (!_loadConnectionsFetcher.isClosed) {
      _loadConnectionsFetcher.sink.add(result);
    }
  }

  dispose() {
    _loadConnectionsFetcher.close();
  }
}
