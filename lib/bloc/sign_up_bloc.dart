import 'package:contractor_search/model/location.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SignUpBloc {
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
                        create_user(
                            name: "Petrea Loredana", 
                            location: 3, 
                            id: "M0TvsVdiaGUnqUqu6rZJRBpw19b2", 
                            phoneNumber: "123423243242") {
                                  name
                                  id
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
                        phoneNumber
                        id
                    }
              }''',
    ));
    return result;
  }
}
