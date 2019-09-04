import 'package:graphql_flutter/graphql_flutter.dart';

class AccountBloc {
  void dispose() {}

  static HttpLink link =
      HttpLink(uri: 'https://xfriendstest.azurewebsites.net');
  GraphQLClient client = GraphQLClient(
    cache: InMemoryCache(),
    link: link,
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
                            name
                        }
                    }
              }''',
    ));

    return result;
  }
}
