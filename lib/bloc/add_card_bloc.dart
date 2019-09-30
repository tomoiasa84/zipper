import 'package:contractor_search/utils/custom_auth_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AddCardBloc {
  void dispose() {}

  static HttpLink link =
      HttpLink(uri: 'https://xfriendstest.azurewebsites.net');

  static final CustomAuthLink _authLink = CustomAuthLink();

  GraphQLClient client = GraphQLClient(
    cache: InMemoryCache(),
    link: _authLink.concat(link),
  );

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
                          user{
                            name
                          }
                        }
                        description
                    }
              }''',
    ));

    return result;
  }

  Future<QueryResult> getTags() async {
    final QueryResult result = await client.query(QueryOptions(
      document: '''query{
                      get_tags{
                        id
                        name
                      }
                    }''',
    ));

    return result;
  }

  Future<QueryResult> createCard(
      String postedBy, int searchFor, String details) async {
    final QueryResult result = await client.query(QueryOptions(
      document: '''mutation{
                      create_card(postedBy:"$postedBy", searchFor:$searchFor, text:"$details"){
                        id
                        postedBy{
                          name
                          id
                        }
                        searchFor{
                          name
                          id
                        }
                        createdAt
                        text
                      }
                    }''',
    ));

    return result;
  }
}
