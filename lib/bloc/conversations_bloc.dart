import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:rxdart/rxdart.dart';

class ConversationsBloc {
  final _getPubNubConversationsFetcher =
      PublishSubject<List<PubNubConversation>>();

  Observable<List<PubNubConversation>> get getPubNubConversationsObservable =>
      _getPubNubConversationsFetcher.stream;

  getPubNubConversations() async {
    var result = await Repository().getPubNubConversations();
    if (!_getPubNubConversationsFetcher.isClosed) {
      _getPubNubConversationsFetcher.sink.add(result);
    }
  }

  void dispose() {
    _getPubNubConversationsFetcher.close();
  }
}
