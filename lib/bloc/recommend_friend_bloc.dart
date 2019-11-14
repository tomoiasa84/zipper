import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PnGCM.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/global_variables.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class RecommendFriendBloc {

  Future<QueryResult> createRecommend(int cardId, String userAskId, String userRecId) async {
    String userSendId = await getCurrentUserId();
    return await Repository().createRecommends(cardId, userAskId, userSendId, userRecId);
  }

  Future<PubNubConversation> createConversation(User user) async {
    return await Repository().createConversation(user);
  }

  Future<bool> sendMessage(String channelId, PnGCM pnGCM) async {
    return await Repository().sendMessage(channelId, pnGCM);
  }

  Future<QueryResult> getCurrentUserWithConnections() async {
    String userId = await getCurrentUserId();

    return Repository().getUserByIdWithConnections(userId);
  }
}
