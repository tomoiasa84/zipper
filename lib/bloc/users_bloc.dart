import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/utils/custom_auth_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class UsersBloc {
  void dispose() {}

  getContacts() async {
    return ContactsService.getContacts();
  }

  static HttpLink link =
      HttpLink(uri: 'https://xfriendstest.azurewebsites.net');

  static final CustomAuthLink _authLink = CustomAuthLink();

  GraphQLClient client = GraphQLClient(
    cache: InMemoryCache(),
    link: _authLink.concat(link),
  );

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
                            name
                        }
                        cards{
                            text
                        }
                    }
              }''',
    ));

    return result;
  }
}
