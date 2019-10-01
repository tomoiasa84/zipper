import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SelectContactBloc {
  Repository _repository = Repository();

  Future<QueryResult> getUsers() async {
    return _repository.getUsers();
  }

  Future<PubNubConversation> createConversation(User user) async {
    return await _repository.createConversation(user);
  }
}
