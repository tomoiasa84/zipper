import 'package:contractor_search/utils/custom_auth_link.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SendInChatBloc {
  void dispose() {}

  static HttpLink link =
  HttpLink(uri: 'https://xfriendstest.azurewebsites.net');

  static final CustomAuthLink _authLink = CustomAuthLink();

  GraphQLClient client = GraphQLClient(
    cache: InMemoryCache(),
    link: _authLink.concat(link),
  );

  Future<QueryResult> getUsers() async {
    final QueryResult result = await client.query(QueryOptions(
      document: '''query {
                     get_users{
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
                         reviews{
                            author{
                              name
                            }
                            stars
                           userTag{
                            id
                            tag{
                              name
                            }
                            user{
                              name
                            }
                          }
                            text
                          }
                    }
              }''',
    ));

    return result;
  }

}
