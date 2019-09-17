import 'dart:convert';

import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/utils/custom_auth_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SyncContactsBloc {
  void dispose() {}

  static HttpLink link =
      HttpLink(uri: 'https://xfriendstest.azurewebsites.net');

  static final CustomAuthLink _authLink = CustomAuthLink();

  GraphQLClient client = GraphQLClient(
    cache: InMemoryCache(),
    link: _authLink.concat(link),
  );

  Future<Iterable<Contact>> getContacts() async {
    return await ContactsService.getContacts();
  }

  Future<QueryResult> checkContacts(List<String> phoneContacts) async {
    var phoneContactsJson = jsonEncode(phoneContacts);

    final QueryResult queryResult = await client.mutate(
      MutationOptions(
        document: '''query{
                    check_contacts(contactsList: $phoneContactsJson){
                      number
                      exists
                    }
                  }''',
      ),
    );

    return queryResult;
  }

  Future<QueryResult> getCurrentUser(String userId) async {
    final QueryResult result = await client.query(QueryOptions(
      document: '''query{
                     get_user(userId:"$userId"){
                        name
                        phoneNumber
                        id
                        location{
                            id
                            city
                        }
                        isActive
                        connections{
                             name
                        }
                        cards{
                            id
                            createdAt
                            searchFor{
                              name
                            }
                            postedBy{
                                id
                                name
                            }
                            text
                        }
                        tags{
                            id
                            name
                        }
                    }
              }''',
    ));

    return result;
  }
}
