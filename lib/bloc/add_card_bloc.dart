import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rxdart/rxdart.dart';

class AddCardBloc {
  final _getUserNameIdPhoneNumberProfilePicFetcher =
      PublishSubject<QueryResult>();
  final _getCurrentUserWithCardsFetcher = PublishSubject<QueryResult>();
  final _getTagsFetcher = PublishSubject<QueryResult>();
  final _createCardFetcher = PublishSubject<QueryResult>();

  Observable<QueryResult> get getUserNameIdPhoneNumberProfilePicObservable =>
      _getUserNameIdPhoneNumberProfilePicFetcher.stream;

  Observable<QueryResult> get getCurrentUserWithCardsObservable =>
      _getCurrentUserWithCardsFetcher.stream;

  Observable<QueryResult> get getTagsFetcherObservable =>
      _getTagsFetcher.stream;

  Observable<QueryResult> get createCardObservable => _createCardFetcher.stream;

  getUserNameIdPhoneNumberProfilePic(String userId) async {
    QueryResult result =
        await Repository().getUserNameIdPhoneNumberProfilePic(userId);
    if (!_getUserNameIdPhoneNumberProfilePicFetcher.isClosed) {
      _getUserNameIdPhoneNumberProfilePicFetcher.sink.add(result);
    }
  }

  getCurrentUserWithCards(String userId) async {
    QueryResult result = await Repository().getCurrentUserWithCards(userId);
    if (!_getCurrentUserWithCardsFetcher.isClosed) {
      _getCurrentUserWithCardsFetcher.sink.add(result);
    }
  }

  getTags() async {
    QueryResult result = await Repository().getTags();
    if (!_getTagsFetcher.isClosed) {
      _getTagsFetcher.sink.add(result);
    }
  }

  createCard(String postedBy, int searchFor, String details) async {
    QueryResult result =
        await Repository().createCard(postedBy, searchFor, details);
    if (!_createCardFetcher.isClosed) {
      _createCardFetcher.sink.add(result);
    }
  }

  dispose() {
    _getUserNameIdPhoneNumberProfilePicFetcher.close();
    _getCurrentUserWithCardsFetcher.close();
    _getTagsFetcher.close();
    _createCardFetcher.close();
  }
}
