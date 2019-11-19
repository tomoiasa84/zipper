import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PnGCM.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rxdart/rxdart.dart';

class SendInChatBloc {
  String _currentUserId;

  final _getCurrentUserWithConnectionsFetcher = PublishSubject<QueryResult>();
  final _createConversationFetcher = PublishSubject<PubNubConversation>();
  final _sendMessageFetcher = PublishSubject<bool>();
  final _getRecentUsersFetcher = PublishSubject<List<User>>();

  Observable<QueryResult> get getCurrentUserWithConnectionsObservable =>
      _getCurrentUserWithConnectionsFetcher.stream;

  Observable<PubNubConversation> get createConversationObservable =>
      _createConversationFetcher.stream;

  Observable<bool> get sendMessageObservable => _sendMessageFetcher.stream;

  Observable<List<User>> get getRecentUsersObservable =>
      _getRecentUsersFetcher.stream;

  getCurrentUserWithConnections() async {
    String userId = await getCurrentUserId();
    QueryResult result = await Repository().getUserByIdWithConnections(userId);
    if (!_getCurrentUserWithConnectionsFetcher.isClosed) {
      _getCurrentUserWithConnectionsFetcher.sink.add(result);
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

  getRecentUsers() async {
    var recentUsers = List<User>();
    _currentUserId = await SharedPreferencesHelper.getCurrentUserId();

    await Repository().getPubNubConversations().then((conversations) {
      if (conversations != null) {
        for (var conversation in conversations) {
          if (conversation.user1 != null && conversation.user2 != null) {
            recentUsers.add(_getInterlocutorUser(conversation));
          }
        }
      }
    });
    if (!_getRecentUsersFetcher.isClosed) {
      _getRecentUsersFetcher.sink.add(recentUsers);
    }
  }

  User _getInterlocutorUser(PubNubConversation pubNubConversation) {
    if (pubNubConversation.user1.id == _currentUserId) {
      return pubNubConversation.user2;
    } else {
      return pubNubConversation.user1;
    }
  }

  dispose() {
    _getCurrentUserWithConnectionsFetcher.close();
    _sendMessageFetcher.close();
    _getRecentUsersFetcher.close();
    _createConversationFetcher.close();
  }
}
