import 'package:graphql_flutter/graphql_flutter.dart';

class LoginBloc {
  void dispose() {}

  static HttpLink link =
      HttpLink(uri: 'https://xfriendstest.azurewebsites.net');
  GraphQLClient client = GraphQLClient(
    cache: InMemoryCache(),
    link: link,
  );

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
