import 'dart:convert';

import 'package:contractor_search/utils/custom_auth_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ShareSelectedBloc {
  void dispose() {}

  static HttpLink link =
  HttpLink(uri: 'https://xfriendstest.azurewebsites.net');

  static final CustomAuthLink _authLink = CustomAuthLink();

  GraphQLClient client = GraphQLClient(
    cache: InMemoryCache(),
    link: _authLink.concat(link),
  );

  Future<QueryResult> loadContacts(List<String> phoneContacts) async {
    var phoneContactsJson = jsonEncode(phoneContacts);

    final QueryResult queryResult = await client.mutate(
      MutationOptions(
        document: '''mutation{
                         load_contacts(phoneContacts: $phoneContactsJson) {
                           name
                           id
                           phoneNumber
                           location{
                                 id
                                 city
                             }
                                tags{
                                    name
                                }
                                cards{
                                    text
                                }
                         }
                  }''',
      ),
    );

    return queryResult;
  }
}
