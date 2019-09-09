import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ProfileSettingsBloc {
  void dispose() {}

  static HttpLink link =
      HttpLink(uri: 'https://xfriendstest.azurewebsites.net');

  static final AuthLink _authLink = AuthLink(
      getToken: () async => await SharedPreferencesHelper.getAccessToken());

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
                                  thread_messages{
                                      users{
                                          name
                                        }
                                }
                    }
                  }''',
      ),
    );

    return queryResult;
  }
}
