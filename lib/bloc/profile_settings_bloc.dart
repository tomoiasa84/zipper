import 'package:graphql_flutter/graphql_flutter.dart';

class ProfileSettingsBloc {
  void dispose() {}

  static HttpLink link =
  HttpLink(uri: 'https://xfriendstest.azurewebsites.net');
  GraphQLClient client = GraphQLClient(
    cache: InMemoryCache(),
    link: link,
  );

  Future<QueryResult> updateUser(
      String name, int location, String id, String phoneNumber, bool isActive) async {
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
