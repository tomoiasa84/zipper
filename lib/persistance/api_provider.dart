import 'dart:convert';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:contractor_search/model/conversation_model.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PnGCM.dart';
import 'package:contractor_search/utils/custom_auth_link.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;

class ApiProvider {
  static HttpLink link =
      HttpLink(uri: 'https://xfriendstest.azurewebsites.net');

  static final CustomAuthLink _authLink = CustomAuthLink();

  final String _publishKey = "pub-c-202b96b5-ebbe-4a3a-94fd-dc45b0bd382e";
  final String _subscribeKey = "sub-c-e742fad6-c8a5-11e9-9d00-8a58a5558306";
  final String _baseUrl = "https://ps.pndsn.com";
  final http.Client _pubNubClient = new http.Client();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  GraphQLClient _client = GraphQLClient(
    cache: InMemoryCache(),
    link: _authLink.concat(link),
  );

  GraphQLClient _unauthenticatedClient = GraphQLClient(
    cache: InMemoryCache(),
    link: link,
  );

  Future<QueryResult> getUserById(String userId) async {
    final QueryResult result = await _client.query(QueryOptions(
      document: '''query{
                     get_user(userId:"$userId"){
                        name
                        phoneNumber
                        id
                        location{
                            id
                            city
                        }
                        isActive
                        connections{
                             name
                        }
                        cards{
                            id
                            createdAt
                            searchFor{
                              name
                            }
                            postedBy{
                                id
                                name
                            }
                            text
                        }
                        description
                        tags{
                          id
                          default
                          user{
                            name
                          }
                          tag{
                            id
                            name
                          }
                          score
                          reviews{
                            author{
                              name
                            }
                            stars
                           userTag{
                            id
                            tag{
                              name
                            }
                            user{
                              name
                            }
                            reviews{
                              id
                              author{
                                name
                              }
                              userTag{
                                 id
                                 score
                              }
                              stars
                              text
                            }
                            score
                          }
                            text
                          }
                        }
                         reviews{
                            author{
                              name
                            }
                            stars
                           userTag{
                            id
                            tag{
                              name
                            }
                            user{
                              name
                            }
                            reviews{
                              id
                              author{
                                name
                              }
                              userTag{
                                 id
                                 score
                              }
                              stars
                              text
                            }
                            score
                          }
                            text
                          }
                    }
              }''',
    ));

    return result;
  }

  Future<QueryResult> deleteCard(int cardId) async {
    final QueryResult result = await _client.query(QueryOptions(
      document: '''mutation{
                      delete_card(cardId:$cardId)
                    }''',
    ));

    return result;
  }

  Future<QueryResult> getTags() async {
    final QueryResult result = await _client.query(QueryOptions(
      document: '''query{
                      get_tags{
                        id
                        name
                      }
                    }''',
    ));

    return result;
  }

  Future<QueryResult> createCard(
      String postedBy, int searchFor, String details) async {
    final QueryResult result = await _client.query(QueryOptions(
      document: '''mutation{
                      create_card(postedBy:"$postedBy", searchFor:$searchFor, text:"$details"){
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
                      }
                    }''',
    ));

    return result;
  }

  Future<QueryResult> getConversation(String conversationId) async {
    final QueryResult result = await _client.query(QueryOptions(
      document: '''query{
                    get_conversation(conversationId: "$conversationId"){
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

    return result;
  }

  Future<QueryResult> createConversation(
      User user, String currentUserId) async {
    String userId = user.id;

    final QueryResult result = await _client.query(QueryOptions(
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

    return result;
  }

  Future<List<ConversationModel>> getListOfIdsFromBackend(
      String currentUserId) async {
    final QueryResult result = await _client.query(QueryOptions(
      document: '''query{
                    get_user(userId: "$currentUserId"){
                      conversations{
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
                    }
                }''',
    ));
    User currentUser = User.fromJson(result.data['get_user']);

    return currentUser.conversations;
  }

  Future<QueryResult> getCards() async {
    final QueryResult result = await _client.query(QueryOptions(
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
                      recommandsCount
                      recommandsList{
                         id
                         card{
                           id
                         }
                         userAsk{
                           name
                         }
                         userSend{
                           name
                         }
                         userRecommand{
                           name
                         }
                         acceptedFlag
                      }
                    }
                  }''',
    ));

    return result;
  }

  Future<QueryResult> updateUser(String name, int location, String id,
      String phoneNumber, bool isActive, String description) async {
    final QueryResult queryResult = await _client.mutate(
      MutationOptions(
        document: '''
                    mutation{
                           update_user(userId: "$id",
                            name: "$name", 
                            location: $location,
                            isActive: $isActive,
                            phoneNumber: "$phoneNumber",
                            description: "$description") {
                              name
                              phoneNumber
                              id
                              location{
                                  id
                                  city
                              }
                              isActive
                              connections{
                                   name
                              }
                              cards{
                                  id
                                  createdAt
                                  searchFor{
                                    name
                                  }
                                  postedBy{
                                      id
                                      name
                                  }
                                  text
                              }
                              description
                              tags{
                                id
                                default
                                user{
                                  name
                                }
                                tag{
                                  id
                                  name
                                }
                              }
                    }
                  }''',
      ),
    );

    return queryResult;
  }

  Future<QueryResult> createUserTag(String userId, int tagId) async {
    final QueryResult queryResult = await _client.mutate(
      MutationOptions(
        document: '''mutation{
                          create_userTag(userId:"$userId",
                          tagId: $tagId){
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
                        }''',
      ),
    );

    return queryResult;
  }

  Future<QueryResult> updateMainUserTag(int userTagId, bool defaultFlag) async {
    final QueryResult queryResult = await _client.mutate(
      MutationOptions(
        document: '''mutation{
                          update_userTag(userTagId:$userTagId, defaultFlag:$defaultFlag){
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
                        }''',
      ),
    );

    return queryResult;
  }

  Future<QueryResult> deleteUserTag(int userTagId) async {
    final QueryResult queryResult = await _client.mutate(
      MutationOptions(
        document: '''mutation{
                       delete_userTag(userTagId:$userTagId)
                      }''',
      ),
    );

    return queryResult;
  }

  Future<QueryResult> getUsers() async {
    final QueryResult result = await _client.query(QueryOptions(
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
                          id
                          user{
                            id
                            name
                          }
                          tag{
                            id
                            name
                          }
                          score
                          reviews{
                            author{
                              name
                            }
                            stars
                           userTag{
                            id
                            tag{
                              name
                            }
                            user{
                              name
                            }
                            reviews{
                              id
                              author{
                                name
                              }
                              userTag{
                                 id
                                 score
                              }
                              stars
                              text
                            }
                            score
                          }
                            text
                          }
                          default
                        }
                        description
                        cards{
                            text
                        }
                         reviews{
                            author{
                              name
                            }
                            stars
                           userTag{
                            id
                            tag{
                              name
                            }
                            user{
                              name
                            }
                            reviews{
                              id
                              author{
                                name
                              }
                              userTag{
                                 id
                                 score
                              }
                              stars
                              text
                            }
                            score
                          }
                            text
                          }
                    }
              }''',
    ));

    return result;
  }

  Future<QueryResult> loadContacts(List<String> phoneContacts) async {
    var phoneContactsJson = jsonEncode(phoneContacts);

    final QueryResult queryResult = await _client.mutate(
      MutationOptions(
        document: '''mutation{
                         load_contacts(phoneContacts: $phoneContactsJson) {
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
                          id
                          user{
                            name
                          }
                        }
                        description
                        cards{
                            text
                        }
                       }
                  }''',
      ),
    );

    return queryResult;
  }

  Future<QueryResult> getLocations() async {
    final QueryResult result = await _unauthenticatedClient.query(QueryOptions(
      // query: readChars,
      document: '''query{
                      get_locations{
                        id
                        city
                      }
                    }''',
    ));

    return result;
  }

  Future<QueryResult> createUser(
      String name, int location, String firebaseId, String phoneNumber) async {
    final QueryResult queryResult = await _client.mutate(
      MutationOptions(
        document: '''mutation{
                           create_user(firebaseId: "$firebaseId",
                            name: "$name", 
                            location: $location,  
                            phoneNumber: "$phoneNumber") {
                                 	name
                        					id
                        					firebaseId
                        					phoneNumber
                        					location{
                           						 id
                           						 city
                       						 }
                    }
                  }''',
      ),
    );

    return queryResult;
  }

  Future<QueryResult> createLocation(String city) async {
    final QueryResult result = await _client.mutate(
      MutationOptions(
        document: '''mutation{
                        create_location(city: "$city"){
                          city
                          id
                        }
                      }''',
      ),
    );

    return result;
  }

  Future<QueryResult> checkContacts(List<String> phoneContacts) async {
    var phoneContactsJson = jsonEncode(phoneContacts);

    final QueryResult queryResult = await _client.mutate(
      MutationOptions(
        document: '''query{
                    check_contacts(contactsList: $phoneContactsJson){
                      number
                      exists
                    }
                  }''',
      ),
    );

    return queryResult;
  }

  Future<QueryResult> createReview(
      String userId, int userTagId, int stars, String text) async {
    final QueryResult result = await _client.mutate(
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
                            id
                            tag{
                              name
                            }
                            user{
                              name
                            }
                            reviews{
                              id
                              author{
                                name
                              }
                              userTag{
                                 id
                                 score
                              }
                              stars
                              text
                            }
                            score
                          }
                          stars
                          text
                        }
                      }''',
      ),
    );

    return result;
  }

  void subscribeToPushNotifications(String channelId) async {
    _firebaseMessaging.getToken().then((deviceId) {
      print('DEVICE ID: $deviceId');
      var url =
          "$_baseUrl/v1/push/sub-key/$_subscribeKey/devices/$deviceId?add=$channelId&type=gcm";
      _pubNubClient.get(url);
    });
  }

  Future unsubscribeFromPushNotifications(String channels) async {
    _firebaseMessaging.getToken().then((deviceId) {
      var url =
          "$_baseUrl/v1/push/sub-key/$_subscribeKey/devices/$deviceId?remove=$channels&type=gcm";
      _pubNubClient.get(url);
    });
  }

  Future<String> uploadPic(File image) async {
    final StorageReference reference =
        _storage.ref().child(DateTime.now().toIso8601String());
    final StorageUploadTask uploadTask = reference.putFile(image);
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    return url;
  }

  Future<bool> sendMessage(String channelId, PnGCM pnGCM) async {
    var encodedMessage = convert.jsonEncode(pnGCM.toJson());
    var url =
        "$_baseUrl/publish/$_publishKey/$_subscribeKey/0/$channelId/myCallback/$encodedMessage";

    var response = await _pubNubClient.get(url);
    if (response.statusCode == 200) {
      return true;
    } else {
      print("Request failed with status: ${response.body}.");
      return false;
    }
  }

  Future<http.Response> getHistoryMessages(
      String channelName, int historyStart, int numberOfMessagesToFetch) async {
    var url;

    if (historyStart == null) {
      url =
          "$_baseUrl/v2/history/sub-key/$_subscribeKey/channel/$channelName?count=$numberOfMessagesToFetch";
    } else {
      url =
          "$_baseUrl/v2/history/sub-key/$_subscribeKey/channel/$channelName?count=$numberOfMessagesToFetch&start=$historyStart";
    }

    return await _pubNubClient.get(url);
  }

  Future<http.Response> subscribeToChannel(
      String channelName, String currentUserId, String timestamp) async {
    var url =
        "$_baseUrl/subscribe/$_subscribeKey/$channelName/0/$timestamp?uuid=$currentUserId";
    return await _pubNubClient.get(url);
  }

  Future<http.Response> getPubNubConversations(String channels) async {
    var url =
        "$_baseUrl/v3/history/sub-key/$_subscribeKey/channel/$channels?max=1";
    return await _pubNubClient.get(url);
  }

  void dispose() {
    _pubNubClient.close();
  }

  Future<QueryResult> createRecommend(
      int cardId, String userAskId, String userSendId, String userRecId) async {
    final QueryResult result = await _client.mutate(
      MutationOptions(
        document: '''mutation{
                            create_recommand(cardId:$cardId, userAskId:"$userAskId", userSendId:"$userSendId", userRecId:"$userRecId"){
                              id
                              card{
                                id
                              }
                              userAsk{
                                name
                              }
                              userSend{
                                name
                              }
                              userRecommand{
                                name
                              }
                              acceptedFlag
                            }
                          }''',
      ),
    );

    return result;
  }
}
