import 'package:contractor_search/utils/custom_auth_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SmsCodeVerificationBloc {
  void dispose() {}

  static HttpLink link =
      HttpLink(uri: 'https://xfriendstest.azurewebsites.net');

  static final CustomAuthLink _authLink = CustomAuthLink();

  GraphQLClient client = GraphQLClient(
    cache: InMemoryCache(),
    link: _authLink.concat(link),
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
      String name, int location, String firebaseId, String phoneNumber) async {
    final QueryResult queryResult = await client.mutate(
      MutationOptions(
        document: '''mutation{
                           create_user(firebaseId: "$firebaseId",
                            name: "$name", 
                            location: $location,  
                            phoneNumber: "$phoneNumber") {
                                 	name
                        					id
                        					firebaseId
                        					phoneNumber
                        					location{
                           						 id
                           						 city
                       						 }
                    }
                  }''',
      ),
    );

    return queryResult;
  }

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
                        					firebaseId
                        					phoneNumber
                        					isActive
                        					location{
                           						 id
                           						 city
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
                    }
              }''',
    ));
    return result;
  }
}
