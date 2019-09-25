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
                        firebaseId
                        id
                        phoneNumber
                        isActive
                        location{
                            id
                            city
                        }
                        tags{
                          id
                          user{
                            name
                          }
                        }
                        description
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
