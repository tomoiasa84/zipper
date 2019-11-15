import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rxdart/rxdart.dart';

class UsersBloc {
  final _getCurrentUserWithConnectionsFetcher = PublishSubject<QueryResult>();

  Observable<QueryResult> get getUserByIdWithConnectionObservable =>
      _getCurrentUserWithConnectionsFetcher.stream;

  getCurrentUserWithConnections() async {
    String userId = await getCurrentUserId();
    var result = await Repository().getUserByIdWithConnections(userId);
    if (!_getCurrentUserWithConnectionsFetcher.isClosed) {
      _getCurrentUserWithConnectionsFetcher.sink.add(result);
    }
  }

  dispose() {
    _getCurrentUserWithConnectionsFetcher.close();
  }
}
