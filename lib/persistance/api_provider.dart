import 'dart:convert';

import 'package:contractor_search/model/conversation_model.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/utils/custom_auth_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ApiProvider {
  static HttpLink link =
      HttpLink(uri: 'https://xfriendstest.azurewebsites.net');

  static final CustomAuthLink _authLink = CustomAuthLink();

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
                      recommands
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
