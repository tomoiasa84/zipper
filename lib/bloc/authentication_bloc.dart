import 'package:graphql_flutter/graphql_flutter.dart';

class AuthenticationBloc {
  void dispose() {}

  static HttpLink link =
      HttpLink(uri: 'https://xfriendstest.azurewebsites.net');
  GraphQLClient client = GraphQLClient(
    cache: InMemoryCache(),
    link: link,
  );

  Future<QueryResult> getLocations() async {
    final QueryResult queryResult = await client.query(QueryOptions(
      // query: readChars,
      document: '''query{
                      get_locations{
                        id
                        city
                      }
                    }''',
    ));

    return queryResult;
  }

  Future<QueryResult> createUser(
      String name, int location, String id, String phoneNumber) async {
    final QueryResult queryResult = await client.mutate(
      MutationOptions(
        document: '''mutation{
                           create_user(id: "$id",
                            name: "$name", 
                            location: $location,  
                            phoneNumber: "$phoneNumber") {
                                 	name
                        					id
                        					phoneNumber
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

  Future<QueryResult> createLocation(String city) async {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: '''mutation{
                        create_location(city: "$city"){
                          city
                          id
                        }
                      }''',
      ),
    );

    return result;
  }

  Future<QueryResult> getUsers() async {
    final QueryResult result = await client.query(QueryOptions(
      document: '''query {
                     get_users{
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
    ));
    return result;
  }
}