import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/model/conversation_model.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/utils/custom_auth_link.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SelectContactBloc {
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
                    }
              }''',
    ));

    return result;
  }

  Future<PubNubConversation> createConversation(User user) async {
    String userId = user.id;
    return SharedPreferencesHelper.getCurrentUserId()
        .then((currentUserId) async {
      final QueryResult result = await client.query(QueryOptions(
        document: '''mutation{
                      create_conversation(user1:"$currentUserId", user2:"$userId"){
                        id
                        user1{
                          id
                          name
                        }
                        user2{
                          id
                          name
                        }
                      }
                     }''',
      ));
      ConversationModel conversationModel =
          ConversationModel.fromJson(result.data['create_conversation']);
      PubNubConversation pubNubConversation =
          PubNubConversation.fromConversation(conversationModel);
      return pubNubConversation;
    });
  }
}
