import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/custom_auth_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class HomeContentBloc {

  Repository _repository = Repository();

  Future<QueryResult> getCards() async {
    return _repository.getCards();
  }
}
