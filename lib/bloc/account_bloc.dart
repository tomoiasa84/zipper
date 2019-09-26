import 'package:contractor_search/utils/custom_auth_link.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AccountBloc {
  void dispose() {}

  static HttpLink link =
      HttpLink(uri: 'https://xfriendstest.azurewebsites.net');

  static final CustomAuthLink _authLink = CustomAuthLink();

  GraphQLClient client = GraphQLClient(
    cache: InMemoryCache(),
    link: _authLink.concat(link),
  );

  Future<String> getCurrentUserId() async {
    return await SharedPreferencesHelper.getCurrentUserId();
  }

  Future<QueryResult> getCurrentUser() async {
    String userId = await getCurrentUserId();
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
                        description
                        tags{
                          id
                          default
                          user{
                            name
                          }
                          tag{
                            id
                            name
                          }
                        }
                         reviews{
                            author{
                              name
                            }
                            stars
                           userTag{
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

  Future<QueryResult> deleteCard(int cardId) async {
    final QueryResult result = await client.query(QueryOptions(
      document: '''mutation{
                      delete_card(cardId:$cardId)
                    }''',
    ));

    return result;
  }

  Future removeSharedPreferences() async {
    await FirebaseAuth.instance.signOut().then((_) async {
      await SharedPreferencesHelper.clear();
    });
  }
}
