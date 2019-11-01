import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AddCardBloc {

  Repository _repository = Repository();

  Future<QueryResult> getUserNameIdPhoneNumberProfilePic(String userId) async {
    return _repository.getUserNameIdPhoneNumberProfilePic(userId);
  }

  Future<QueryResult> getCurrentUserWithCards(String userId) async {
    return _repository.getCurrentUserWithCards(userId);
  }

  Future<QueryResult> getTags() async {
    return _repository.getTags();
  }

  Future<QueryResult> createCard(
      String postedBy, int searchFor, String details) async {
    return _repository.createCard(postedBy, searchFor, details);
  }
}
