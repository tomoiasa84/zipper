import 'dart:async';

import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PnGCM.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SendInChatBloc {
  Repository _repository = Repository();

  Future<QueryResult> getUsers() async {
    return _repository.getUsers();
  }

  Future<List<PubNubConversation>> getPubNubConversations() async {
    return _repository.getPubNubConversations();
  }

  Future<PubNubConversation> createConversation(User user) async {
    return await _repository.createConversation(user);
  }

  Future<bool> sendMessage(String channelId, PnGCM pnGCM) async {
    return _repository.sendMessage(channelId, pnGCM);
  }
}
