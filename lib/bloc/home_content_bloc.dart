import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/utils/custom_auth_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class HomeContentBloc {
  void dispose() {}

  static HttpLink link =
  HttpLink(uri: 'https://xfriendstest.azurewebsites.net');

  static final CustomAuthLink _authLink = CustomAuthLink();

  GraphQLClient client = GraphQLClient(
    cache: InMemoryCache(),
    link: _authLink.concat(link),
  );

  Future<QueryResult> getPosts() async {
    final QueryResult result = await client.query(QueryOptions(
      document: '''query{
                    get_cards{
                      id
                      postedBy{
                        name
                        id
                      }
                      searchFor{
                        name
                        id
                      }
                      createdAt
                      text
                      recommands
                    }
                  }''',
    ));

    return result;
  }
}
