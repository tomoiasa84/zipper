import 'package:contractor_search/model/location.dart';
import 'package:contractor_search/utils/custom_auth_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ReviewBloc {
  void dispose() {}

  static HttpLink link =
  HttpLink(uri: 'https://xfriendstest.azurewebsites.net');

  static final CustomAuthLink _authLink = CustomAuthLink();

  GraphQLClient client = GraphQLClient(
    cache: InMemoryCache(),
    link: _authLink.concat(link),
  );


  Future<QueryResult>  createReview(String userId, int userTagId, int stars, String text) async {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: '''mutation{
                        create_review(userId:"$userId", 
                          userTagId:$userTagId,
                        stars:$stars,
                        text:"$text"){
                          id
                          author{
                            name
                          }
                          userTag{
                            user{
                              name
                            }
                            tag{
                              name
                            }
                          }
                          stars
                          text
                        }
                      }''',
      ),
    );

    return result;
  }
}
