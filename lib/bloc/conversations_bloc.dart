import 'dart:async';

import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/global_variables.dart';

class ConversationsBloc {
  final StreamController ctrl = StreamController();

  Future<List<PubNubConversation>> getPubNubConversations() async {
    return Repository().getPubNubConversations();
  }

  void dispose() {
    ctrl.close();
  }
}
