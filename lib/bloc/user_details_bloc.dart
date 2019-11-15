import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rxdart/rxdart.dart';

class UserDetailsBloc {
  final _getUserByIdWithMainInfoFetcher = PublishSubject<QueryResult>();
  final _getUserByIdWithConnectionsFetcher = PublishSubject<QueryResult>();
  final _createConversationFetcher = PublishSubject<PubNubConversation>();
  final _createConnectionFetcher = PublishSubject<QueryResult>();
  final _deleteConnectionFetcher = PublishSubject<QueryResult>();
  final _createReviewFetcher = PublishSubject<QueryResult>();
  final _addContactFetcher = PublishSubject<dynamic>();

  Observable<QueryResult> get getUserByIdWithMainInfoObservable =>
      _getUserByIdWithMainInfoFetcher.stream;

  Observable<QueryResult> get getUserByIdWithConnectionsObservable =>
      _getUserByIdWithConnectionsFetcher.stream;

  Observable<PubNubConversation> get createConversationObservable =>
      _createConversationFetcher.stream;

  Observable<QueryResult> get createConnectionObservable =>
      _createConnectionFetcher.stream;

  Observable<QueryResult> get deleteConnectionObservable =>
      _deleteConnectionFetcher.stream;

  Observable<QueryResult> get createReviewObservable =>
      _createReviewFetcher.stream;

  Observable<dynamic> get addContactObservable => _addContactFetcher.stream;

  getUserByIdWithMainInfo(String userId) async {
    QueryResult result = await Repository().getUserByIdWithMainInfo(userId);
    if (!_getUserByIdWithMainInfoFetcher.isClosed) {
      _getUserByIdWithMainInfoFetcher.sink.add(result);
    }
  }

  getUserByIdWithConnections(String userId) async {
    QueryResult result = await Repository().getUserByIdWithConnections(userId);
    if (!_getUserByIdWithConnectionsFetcher.isClosed) {
      _getUserByIdWithConnectionsFetcher.sink.add(result);
    }
  }

  createConversation(User user) async {
    PubNubConversation result = await Repository().createConversation(user);
    if (!_createConversationFetcher.isClosed) {
      _createConversationFetcher.sink.add(result);
    }
  }

  createConnection(String currentUserId, String targetUserId) async {
    QueryResult result =
        await Repository().createConnection(currentUserId, targetUserId);
    if (!_createConnectionFetcher.isClosed) {
      _createConnectionFetcher.sink.add(result);
    }
  }

  deleteConnection(int connectionId) async {
    QueryResult result = await Repository().deleteConnection(connectionId);
    if (!_deleteConnectionFetcher.isClosed) {
      _deleteConnectionFetcher.sink.add(result);
    }
  }

  createReview(String userId, int userTagId, int stars, String text) async {
    QueryResult result = await Repository().createReview(
        userId, userTagId, stars, removeMultilineCharacters(text));
    if (!_createReviewFetcher.isClosed) {
      _createReviewFetcher.sink.add(result);
    }
  }

  addContact(String displayName, String phoneNumber) {
    Contact contact = Contact();
    contact.familyName = displayName;
    contact.phones = [Item(label: "mobile", value: phoneNumber)];
    if (!_addContactFetcher.isClosed) {
      _addContactFetcher.sink.add(ContactsService.addContact(contact));
    }
  }

  dispose() {
    _getUserByIdWithConnectionsFetcher.close();
    _getUserByIdWithMainInfoFetcher.close();
    _createConversationFetcher.close();
    _createConnectionFetcher.close();
    _deleteConnectionFetcher.close();
    _createReviewFetcher.close();
    _addContactFetcher.close();
  }
}
