import 'package:contractor_search/model/phoneContactInput.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rxdart/rxdart.dart';

class ShareSelectedBloc {
  final _loadContactsFetcher = PublishSubject<QueryResult>();
  final _loadAgendaFetcher = PublishSubject<QueryResult>();
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
  loadAgenda(List<PhoneContactInput> phoneContacts) async {
    print("Hit bloc function");
    print(phoneContacts.length);
    QueryResult result = await Repository().loadAgenda(phoneContacts);
    if (!_loadAgendaFetcher.isClosed) {
      _loadAgendaFetcher.sink.add(result);
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
//  Future<QueryResult> loadAgenda(List<PhoneContactInput> phoneContacts) async {
//    print("Hit bloc function");
//    print(phoneContacts.length);
//    return await _repository.loadAgenda(phoneContacts);
//  }
}
