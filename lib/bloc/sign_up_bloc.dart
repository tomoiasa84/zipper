import 'package:contractor_search/model/location.dart';
import 'package:contractor_search/utils/custom_auth_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SignUpBloc {
  void dispose() {}

  static HttpLink link =
  HttpLink(uri: 'https://xfriendstest.azurewebsites.net');

  static final CustomAuthLink _authLink = CustomAuthLink();

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
    locations.forEach((location) => list.add(LocationModel.fromJson(location)));
    return list;
  }
}
