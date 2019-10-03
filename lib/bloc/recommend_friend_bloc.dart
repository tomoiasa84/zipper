import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PnGCM.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class RecommendFriendBloc {
  Repository _repository = Repository();

  Future<QueryResult> getUsers() async {
    return _repository.getUsers();
  }

  Future<QueryResult> createRecommend(int cardId, String userAskId, String userRecId) async {
    String userSendId = await getCurrentUserId();
    return await _repository.createRecommends(cardId, userAskId, userSendId, userRecId);
  }

  Future<PubNubConversation> createConversation(User user) async {
    return await _repository.createConversation(user);
  }

  Future<bool> sendMessage(String channelId, PnGCM pnGCM) async {
    return await _repository.sendMessage(channelId, pnGCM);
  }
}
