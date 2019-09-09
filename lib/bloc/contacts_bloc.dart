import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ContactsBloc {
  void dispose() {}

  getContacts() async {
    return ContactsService.getContacts();
  }

  static HttpLink link =
  HttpLink(uri: 'https://xfriendstest.azurewebsites.net');

  static final AuthLink _authLink = AuthLink(
      getToken: () async => await SharedPreferencesHelper.getAccessToken());

  GraphQLClient client = GraphQLClient(
    cache: InMemoryCache(),
    link: _authLink.concat(link),
  );

  Future<List<Map<String, dynamic>>> getUsers() async {
    final QueryResult data = await client.query(QueryOptions(
      document: '''query {
                     get_users{
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
    ));

    final List<Map<String, dynamic>> users =
        data.data['get_users'].cast<Map<String, dynamic>>();
    return users;
  }
}
