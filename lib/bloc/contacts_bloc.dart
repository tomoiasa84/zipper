import 'package:contacts_service/contacts_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ContactsBloc {
  void dispose() {}

  getContacts() async {
    return ContactsService.getContacts();
  }

  static HttpLink link = HttpLink(uri: 'https://xfriendstest.azurewebsites.net');
  GraphQLClient client = GraphQLClient(
    cache: InMemoryCache(),
    link: link,
  );

  Future<List<Map<String, dynamic>>> getUsers() async {
    final QueryResult data = await client.query(QueryOptions(
      // query: readChars,
      document: '''query {
                     get_users{
                        name
                    }
              }''',
    ));

    final List<Map<String, dynamic>> users =
        data.data['get_users'].cast<Map<String, dynamic>>();
    return users;
  }
}
