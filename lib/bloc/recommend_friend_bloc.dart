import 'package:contractor_search/utils/custom_auth_link.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class RecommendFriendBloc {
  void dispose() {}

  static HttpLink _link =
      HttpLink(uri: 'https://xfriendstest.azurewebsites.net');

  static final CustomAuthLink _authLink = CustomAuthLink();

  GraphQLClient _client = GraphQLClient(
    cache: InMemoryCache(),
    link: _authLink.concat(_link),
  );

  Future<String> getCurrentUserId() async {
    return await SharedPreferencesHelper.getCurrentUserId();
  }

  Future<QueryResult> getUsers() async {
    final QueryResult result = await _client.query(QueryOptions(
      document: '''query{
                     get_users{
                        name
                        id
                        isActive
                        tags{
                          id
                          user{
                            name
                          }
                          tag{
                            id
                            name
                          }
                          default
                        }
                    }
              }''',
    ));

    return result;
  }
}
