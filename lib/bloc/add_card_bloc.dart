import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AddCardBloc {
  Future<QueryResult> getUserNameIdPhoneNumberProfilePic(String userId) async {
    return Repository().getUserNameIdPhoneNumberProfilePic(userId);
  }

  Future<QueryResult> getCurrentUserWithCards(String userId) async {
    return Repository().getCurrentUserWithCards(userId);
  }

  Future<QueryResult> getTags() async {
    return Repository().getTags();
  }

  Future<QueryResult> createCard(
      String postedBy, int searchFor, String details) async {
    return Repository().createCard(postedBy, searchFor, details);
  }
}
