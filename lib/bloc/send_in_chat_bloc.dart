import 'dart:async';

import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PnGCM.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/global_variables.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SendInChatBloc {
  String _currentUserId;

  Future<QueryResult> getCurrentUserWithConnections() async {
    String userId = await getCurrentUserId();
    return Repository().getUserByIdWithConnections(userId);
  }

  Future<List<PubNubConversation>> getPubNubConversations() async {
    return Repository().getPubNubConversations();
  }

  Future<PubNubConversation> createConversation(User user) async {
    return await Repository().createConversation(user);
  }

  Future<bool> sendMessage(String channelId, PnGCM pnGCM) async {
    return Repository().sendMessage(channelId, pnGCM);
  }

  Future<List<User>> getRecentUsers() async {
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
    return recentUsers;
  }

  User _getInterlocutorUser(PubNubConversation pubNubConversation) {
    if (pubNubConversation.user1.id == _currentUserId) {
      return pubNubConversation.user2;
    } else {
      return pubNubConversation.user1;
    }
  }
}
