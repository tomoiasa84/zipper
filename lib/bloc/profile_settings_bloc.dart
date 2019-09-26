import 'package:contractor_search/utils/custom_auth_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ProfileSettingsBloc {
  void dispose() {}

  static HttpLink link =
      HttpLink(uri: 'https://xfriendstest.azurewebsites.net');

  static final CustomAuthLink _authLink = CustomAuthLink();

  GraphQLClient client = GraphQLClient(
    cache: InMemoryCache(),
    link: _authLink.concat(link),
  );

  Future<QueryResult> updateUser(String name, int location, String id,
      String phoneNumber, bool isActive, String description) async {
    final QueryResult queryResult = await client.mutate(
      MutationOptions(
        document: '''
                    mutation{
                           update_user(userId: "$id",
                            name: "$name", 
                            location: $location,
                            isActive: $isActive,
                            phoneNumber: "$phoneNumber",
                            description: "$description") {
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
                    }
                  }''',
      ),
    );

    return queryResult;
  }

  Future<QueryResult> createUserTag(String userId, int tagId) async {
    final QueryResult queryResult = await client.mutate(
      MutationOptions(
        document: '''mutation{
                          create_userTag(userId:"$userId",
                          tagId: $tagId){
                            id
                            user{
                              name
                            }
                            tag{
                              id
                              name
                            }
                            default
                          }
                        }''',
      ),
    );

    return queryResult;
  }

  Future<QueryResult> updateMainUserTag(int userTagId, bool defaultFlag) async {
    final QueryResult queryResult = await client.mutate(
      MutationOptions(
        document: '''mutation{
                          update_userTag(userTagId:$userTagId, defaultFlag:$defaultFlag){
                            id
                            user{
                              name
                            }
                            tag{
                              id
                              name
                            }
                            default
                          }
                        }''',
      ),
    );

    return queryResult;
  }

  Future<QueryResult> deleteUserTag(int userTagId) async {
    final QueryResult queryResult = await client.mutate(
      MutationOptions(
        document: '''mutation{
                       delete_userTag(userTagId:$userTagId)
                      }''',
      ),
    );

    return queryResult;
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
}
