import 'dart:convert';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/model/contact_model.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PnGCM.dart';
import 'package:contractor_search/utils/custom_auth_link.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;

class ApiProvider {
  static HttpLink link = HttpLink(uri: 'https://xfriendstest.azurewebsites.net');

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

  Future<QueryResult> getUserNameIdPhoneNumberProfilePic(String userId) async {
    final QueryResult result = await _client.query(QueryOptions(
      document: '''query{
                     get_user(userId:"$userId"){
                        name
                        id
                        firebaseId
                        phoneNumber
                        profileURL
                    }
              }''',
    ));
    return result;
  }

  Future<QueryResult> getUserByIdWithPhoneNumber(String userId) async {
    final QueryResult result = await _client.query(QueryOptions(
      document: '''query{
                     get_user(userId:"$userId"){
                        phoneNumber
                    }
              }''',
    ));
    return result;
  }

  Future<QueryResult> getUserFromContact(String phoneNumber) async {
    final QueryResult result = await _client.query(QueryOptions(
      document: '''query{
                      get_userFromContact(contact:"$phoneNumber"){
                        id
                        isActive
                        phoneNumber
                        firebaseId
                      }
                    }''',
    ));
    return result;
  }

  Future<QueryResult> getUserByIdWithConnections(String userId) async {
    final QueryResult result = await _client.query(QueryOptions(
      document: '''query{
                     get_user(userId:"$userId"){
                        id
                        firebaseId
                        connections{
                            id
                            originUser{
                              id
                             name
                             profileURL
                             isActive
                             phoneNumber
                             tags{
                                  id
                                  default
                                  tag{
                                    id
                                    name
                                  }
                                  score
                                  reviews{
                                     id
                                  }
                             }
                            }
                            targetUser{
                              id
                             name
                             profileURL
                             isActive
                             phoneNumber
                             tags{
                                  id
                                  default
                                  tag{
                                    id
                                    name
                                  }
                                  score
                                  reviews{
                                     id
                                  }
                             }
                            }
                        }
                    }
              }''',
    ));

    return result;
  }

  Future<QueryResult> getUserByIdWithCardsConnections(String userId) async {
    final QueryResult result = await _client.query(QueryOptions(
      document: '''query{
                     get_user(userId:"$userId"){
                     firebaseId
                        cardsConnections{
                           id
                      postedBy{
                        profileURL
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
                           searchFor{
                              id
                              name
                           }
                         }
                         userAsk{
                           id
                           name
                         }
                         userSend{
                           id
                           name
                         }
                         userRecommand{
                           name
                            tags{
                                id
                                default
                                user{
                                  name
                                }
                                score
                                reviews{
                                  id
                                }
                                tag{
                                  id
                                  name
                                }
                              }
                         }
                         acceptedFlag
                      }
                        }
    							}
              }''',
    ));

    return result;
  }

  Future<QueryResult> getCurrentUserWithCards(String userId) async {
    final QueryResult result = await _client.query(QueryOptions(
      document: '''query{
                      get_user(userId:"$userId"){
                        firebaseId
                        cards{
                            id
                            createdAt
                            searchFor{
                              name
                            }
                            postedBy{
                                id
                                name
                                profileURL
                            }
                            text
                            recommandsCount
                            recommandsList{
                               id
                              card{
                                id
                                searchFor{
                                  id
                                  name
                                }
                              }
                              userAsk{
                                id
                                name
                              }
                              userSend{
                                id
                                name
                              }
                              userRecommand{
                                name
                                tags{
                                  id
                                  tag{
                                    id
                                    name
                                  }
                                  score
                                  reviews{
                                     id
                                  }
                                }
                              }
                              acceptedFlag
                            }
                        }
                }
              }''',
    ));

    return result;
  }

  Future<QueryResult> getCurrentUserWithFirebaseId(String userId) async {
    final QueryResult result = await _client.query(QueryOptions(
      document: '''query{
                     get_user(userId:"$userId"){
                        id
                        firebaseId
                     }
                  }
      '''
    ));
    return result;
  }

  Future<QueryResult> getUserById(String userId) async {
    final QueryResult result = await _client.query(QueryOptions(
      document: '''query{
                     get_user(userId:"$userId"){
                        name
                        phoneNumber
                        id
                        firebaseId
                        profileURL
                        location{
                            id
                            city
                        }
                        connections{
                            id
                            originUser{
                              id
                             name
                             profileURL
                             isActive
                             phoneNumber
                             tags{
                                  id
                                  default
                                  tag{
                                    id
                                    name
                                  }
                                  score
                                  reviews{
                                     id
                                  }
                             }
                            }
                            targetUser{
                              id
                             name
                             profileURL
                             isActive
                             phoneNumber
                             tags{
                                  id
                                  default
                                  tag{
                                    id
                                    name
                                  }
                                  score
                                  reviews{
                                     id
                                  }
                             }
                            }
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
                                profileURL
                            }
                            text
                            recommandsCount
                            recommandsList{
                               id
                              card{
                                id
                                searchFor{
                                  id
                                  name
                                }
                              }
                              userAsk{
                                id
                                name
                              }
                              userSend{
                                id
                                name
                              }
                              userRecommand{
                                name
                                tags{
                                  id
                                  tag{
                                    id
                                    name
                                  }
                                  score
                                  reviews{
                                     id
                                  }
                                }
                              }
                              acceptedFlag
                            }
                        }
                        cardsConnections{
                           id
                      postedBy{
                        profileURL
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
                           searchFor{
                              id
                              name
                           }
                         }
                         userAsk{
                           id
                           name
                         }
                         userSend{
                           id
                           name
                         }
                         userRecommand{
                           name
                            tags{
                                id
                                default
                                user{
                                  name
                                }
                                score
                                reviews{
                                  id
                                }
                                tag{
                                  id
                                  name
                                }
                              }
                         }
                         acceptedFlag
                      }
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
                              profileURL
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
                                profileURL
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
                              profileURL
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
                                profileURL
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

  Future<QueryResult> getUserByIdWithMainInfo(String userId) async {
    final QueryResult result = await _client.query(QueryOptions(
      document: '''query{
                     get_user(userId:"$userId"){
                        name
                        phoneNumber
                        id
                        firebaseId
                        profileURL
                        location{
                            id
                            city
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
                                profileURL
                            }
                            text
                            recommandsCount
                            recommandsList{
                               id
                              card{
                                id
                                searchFor{
                                  id
                                  name
                                }
                              }
                              userAsk{
                                id
                                name
                              }
                              userSend{
                                id
                                name
                              }
                              userRecommand{
                                name
                                tags{
                                  id
                                  tag{
                                    id
                                    name
                                  }
                                  score
                                  reviews{
                                     id
                                  }
                                }
                              }
                              acceptedFlag
                            }
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
                              profileURL
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
                                profileURL
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
                              profileURL
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
                                profileURL
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
                          profileURL
                          tags{
                          tag{
                            name
                          }
                          default
                        }
                        }
                        user2{
                          id
                          name
                          profileURL
                          tags{
                          tag{
                            name
                          }
                          default
                        }
                        }
                    }
                   }''',
    ));

    return result;
  }

  Future<QueryResult> createConnection(
      String currentUserId, String targetUserId) async {
    final QueryResult result = await _client.query(QueryOptions(
      document: '''mutation{
                    create_connection(origin:"$currentUserId", target:"$targetUserId"){
                      id
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

  Future<QueryResult> getListOfChannelIdsFromBackend(
      String currentUserId) async {
    final QueryResult result = await _client.query(QueryOptions(
      document: '''query{
                    get_user(userId: "$currentUserId"){
                      conversations{
                        id
                        user1{
                          id
                          name
                          profileURL
                          tags{
                          tag{
                            name
                          }
                          default
                        }
                        }
                        user2{
                          id
                          name
                          profileURL
                          tags{
                          tag{
                            name
                          }
                          default
                        }
                        }
                      }
                    }
                }''',
    ));

    return result;
  }

  Future<QueryResult> getCards() async {
    final QueryResult result = await _client.query(QueryOptions(
      document: '''query{
                    get_cards{
                      id
                      postedBy{
                        name
                        profileURL
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
                           searchFor{
                              id
                              name
                           }
                         }
                         userAsk{
                           id
                           name
                         }
                         userSend{
                           id
                           name
                         }
                         userRecommand{
                           name
                            tags{
                                id
                                default
                                user{
                                  name
                                }
                                score
                                reviews{
                                  id
                                }
                                tag{
                                  id
                                  name
                                }
                              }
                         }
                         acceptedFlag
                      }
                    }
                  }''',
    ));

    return result;
  }

  Future<QueryResult> getCardById(int cardId) async {
    final QueryResult result = await _client.query(QueryOptions(
      document: '''query{
                    get_card(cardId:$cardId){
                      id
                      postedBy{
                        name
                        id
                        profileURL
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
                           searchFor{
                              id
                              name
                           }
                         }
                         userAsk{
                           id
                           name
                         }
                         userSend{
                           id
                           name
                         }
                         userRecommand{
                           name
                           id
                           profileURL
                            tags{
                                id
                                default
                                user{
                                  name
                                }
                                score
                                reviews{
                                  id
                                }
                                tag{
                                  id
                                  name
                                }
                              }
                         }
                         acceptedFlag
                      }
                    }
                  }''',
    ));

    return result;
  }

  Future<QueryResult> updateUser(
      String id,
      String firebaseId,
      String name,
      int location,
      bool isActive,
      String phoneNumber,
      String profilePicUrl,
      String description) async {
    final QueryResult queryResult = await _client.mutate(
      MutationOptions(
        document: '''
                    mutation{
                           update_user(userId: "$id",
                            firebaseId: "$firebaseId",
                            name: "$name", 
                            location: $location,
                            isActive: $isActive,
                            phoneNumber: "$phoneNumber",
                            profileURL: "$profilePicUrl",
                            description: "$description") {
                              name
                              phoneNumber
                              id
                              firebaseId
                              profileURL
                              location{
                                  id
                                  city
                              }
                              isActive
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

  Future<QueryResult> updateDeviceToken(String id, String deviceToken, String firebaseId) async {
    final QueryResult queryResult = await _client.mutate(
      MutationOptions(
        document: '''
                    mutation{
                      update_user(userId: "$id", deviceToken:"$deviceToken", firebaseId: "$firebaseId"){
                        deviceToken
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

  Future<QueryResult> updateMainUserTag(int userTagId) async {
    final QueryResult queryResult = await _client.mutate(
      MutationOptions(
        document: '''mutation{
                          update_userTag(userTagId:$userTagId){
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

  Future<QueryResult> loadContacts(List<String> phoneContacts) async {


    var phoneContactsJson = jsonEncode(phoneContacts);
    final QueryResult queryResult = await _client.mutate(
      MutationOptions(
        document: '''mutation{
                         load_contacts(phoneContacts: $phoneContactsJson) {
                            id
                       }
                  }''',
      ),
    );

    return queryResult;
  }

  Future<QueryResult> loadConnections(List<String> existingUsers) async {
    var existingUsersJson = jsonEncode(existingUsers);

    final QueryResult queryResult = await _client.mutate(
      MutationOptions(
        document: '''mutation{
                        load_connections(existingUsers:$existingUsersJson){
                          id
                          originUser{
                            name
                            id
                          }
                          targetUser{
                            name
                            id
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
                            profileURL
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
                                profileURL
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
    var encodedMessage =
        escapeJsonCharacters(convert.jsonEncode(pnGCM.toJson()));
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
                                id
                                name
                                profileURL
                              }
                              userSend{
                                id
                                name
                                profileURL
                              }
                               userRecommand{
                                   name
                                   id
                                   profileURL
                                    tags{
                                        id
                                        default
                                        reviews{
                                           id
                                        }
                                        user{
                                          name
                                        }
                                        tag{
                                          id
                                          name
                                        }
                                        score
                                      }
                                 }
                              acceptedFlag
                            }
                          }''',
      ),
    );

    return result;
  }

  Future<QueryResult> deleteConnection(int connectionId) async {
    final QueryResult result = await _client.mutate(
      MutationOptions(
        document: '''  mutation{
                delete_connection(connectionId: $connectionId)}''',
      ),
    );

    return result;
  }
}
