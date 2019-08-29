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

  Future<List<LocationModel>> getLocations() async {
    final QueryResult data = await client.query(QueryOptions(
      // query: readChars,
      document: '''query{
                      get_locations{
                        id
                        city
                      }
                    }''',
    ));

    final List<Map<String, dynamic>> locations =
        data.data['get_locations'].cast<Map<String, dynamic>>();
    List<LocationModel> list = [];
    locations.forEach((location)=> list.add(LocationModel.fromJson(location)));
    return list;
  }

  Future<Map<String, dynamic>> createUser(
      String name, int location, String id, String phoneNumber) async {
    final QueryResult data1 = await client.mutate(
      MutationOptions(
        document: '''mutation{
                        create_user(
                            name: $name", 
                            location: $location, 
                            id: $id, 
                            phoneNumber: $phoneNumber") {
                                  name
                                  id
                            }
                        }''',
      ),
    );

    final Map<String, dynamic> user =
        data1.data['create_user'].cast<Map<String, dynamic>>();
    return user;
  }
}
