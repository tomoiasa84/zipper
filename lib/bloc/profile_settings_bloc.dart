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
      String phoneNumber, bool isActive) async {
    final QueryResult queryResult = await client.mutate(
      MutationOptions(
        document: '''mutation{
                           update_user(userId: "$id",
                            name: "$name", 
                            location: $location,  
                            phoneNumber: "$phoneNumber",
                            isActive: $isActive) {
                                 	name
                        					id
                        					phoneNumber
                        					isActive
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
                       delete_userTag(userTagId:2 )
                      }''',
      ),
    );

    return queryResult;
  }
}
