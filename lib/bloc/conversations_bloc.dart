import 'dart:async';

import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/persistance/repository.dart';

class ConversationsBloc {
  Repository _repository = Repository();
  final StreamController ctrl = StreamController();

  Future<List<PubNubConversation>> getPubNubConversations() async {
    return _repository.getPubNubConversations();
  }

  void dispose() {
    _repository.dispose();
    ctrl.close();
  }
}
