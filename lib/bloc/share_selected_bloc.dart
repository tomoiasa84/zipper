import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rxdart/rxdart.dart';

class ShareSelectedBloc {
  final _loadContactsFetcher = PublishSubject<QueryResult>();
  final _loadConnectionsFetcher = PublishSubject<QueryResult>();

  Observable<QueryResult> get loadContactsObservable =>
      _loadContactsFetcher.stream;

  Observable<QueryResult> get loadConnectionsObservable =>
      _loadConnectionsFetcher.stream;

  loadContacts(List<String> phoneContacts) async {
    QueryResult result = await Repository().loadContacts(phoneContacts);
    if (!_loadContactsFetcher.isClosed) {
      _loadContactsFetcher.sink.add(result);
    }
  }

  loadConnections(List<String> existingUsers) async {
    QueryResult result = await Repository().loadConnections(existingUsers);
    if (!_loadConnectionsFetcher.isClosed) {
      _loadConnectionsFetcher.sink.add(result);
    }
  }

  dispose() {
    _loadConnectionsFetcher.close();
    _loadContactsFetcher.close();
  }
}
