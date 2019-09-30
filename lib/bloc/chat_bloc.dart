import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:contractor_search/model/conversation_model.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PnGCM.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/models/UserMessage.dart';
import 'package:contractor_search/utils/custom_auth_link.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;

class ChatBloc {
  final String _publishKey = "pub-c-202b96b5-ebbe-4a3a-94fd-dc45b0bd382e";
  final String _subscribeKey = "sub-c-e742fad6-c8a5-11e9-9d00-8a58a5558306";
  final String _baseUrl = "https://ps.pndsn.com";
  final http.Client _pubNubClient = new http.Client();
  final StreamController ctrl = StreamController();
  List<UserMessage> _messagesList;
  final int _numberOfMessagesToFetch = 100;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  int historyStart;
  String _timestamp = "0";
  FirebaseStorage _storage = FirebaseStorage.instance;

  static HttpLink link =
      HttpLink(uri: 'https://xfriendstest.azurewebsites.net');

  static final CustomAuthLink _authLink = CustomAuthLink();

  GraphQLClient _client = GraphQLClient(
    cache: InMemoryCache(),
    link: _authLink.concat(link),
  );

  Future<List<UserMessage>> getHistoryMessages(String channelName) async {
    var url;

    if (historyStart == null) {
      url =
          "$_baseUrl/v2/history/sub-key/$_subscribeKey/channel/$channelName?count=$_numberOfMessagesToFetch";
    } else {
      url =
          "$_baseUrl/v2/history/sub-key/$_subscribeKey/channel/$channelName?count=$_numberOfMessagesToFetch&start=$historyStart";
    }

    var response = await _pubNubClient.get(url);

    if (response.statusCode == 200) {
      _addHistoryMessagesToList(response);
    } else {
      print("Request failed with status: ${response.statusCode}.");
    }
    return _messagesList;
  }

  Future<String> uploadPic(File image) async {
    final StorageReference reference =
        _storage.ref().child(DateTime.now().toIso8601String());
    final StorageUploadTask uploadTask = reference.putFile(image);
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    return url;
  }

  bool stopFetchingMessages() {
    if (_messagesList != null) {
      return _messagesList.length < _numberOfMessagesToFetch;
    } else {
      return false;
    }
  }

  void _addHistoryMessagesToList(http.Response response) {
    List<dynamic> responseList = convert.jsonDecode(response.body);
    List<dynamic> messagesList = responseList[0];
    historyStart = responseList[1];
    _messagesList = List();

    for (var item in messagesList) {
      PnGCM pnGCM = PnGCM.fromJson(item);
      UserMessage message = pnGCM.wrappedMessage.message;
      _messagesList.add(message);
    }
  }

  void subscribeToChannel(String channelName, String currentUserId) async {
    var url =
        "$_baseUrl/subscribe/$_subscribeKey/$channelName/0/$_timestamp?uuid=$currentUserId";
    var response = await _pubNubClient.get(url);

    if (response.statusCode == 200) {
      var myString = response.body.substring(response.body.length - 19);
      _timestamp = myString.substring(0, myString.length - 2);
      _addMessageToList(response);
      subscribeToChannel(channelName, currentUserId);
    } else {
      print("Subscribe request failed with status: ${response.body}.");
    }
  }

  void _addMessageToList(http.Response response) {
    List<dynamic> messageListenerResponse = convert.jsonDecode(response.body);
    List<dynamic> messagesList = messageListenerResponse[0];

    if (messagesList.length > 0) {
      PnGCM pnGCM = PnGCM.fromJson(messagesList[0]);
      UserMessage message = pnGCM.wrappedMessage.message;
      ctrl.sink.add(message);
    }
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

  Future<PubNubConversation> getConversation(String conversationId) async {
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
    ConversationModel conversationModel =
        ConversationModel.fromJson(result.data['get_conversation']);
    PubNubConversation pubNubConversation =
        PubNubConversation.fromConversation(conversationModel);
    return pubNubConversation;
  }

  Future<PubNubConversation> createConversation(User user) async {
    String userId = user.id;
    return SharedPreferencesHelper.getCurrentUserId()
        .then((currentUserId) async {
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
      ConversationModel conversationModel =
          ConversationModel.fromJson(result.data['create_conversation']);
      PubNubConversation pubNubConversation =
          PubNubConversation.fromConversation(conversationModel);
      return pubNubConversation;
    });
  }

  Future subscribeToPushNotifications(String channelId) async {
    _firebaseMessaging.getToken().then((deviceId) {
      print('DEVICE ID: $deviceId');
      var url =
          "http://ps.pndsn.com/v1/push/sub-key/$_subscribeKey/devices/$deviceId?add=$channelId&type=gcm";
      _pubNubClient.get(url);
    });
  }

  void dispose() {
    _pubNubClient.close();
    ctrl.close();
  }
}
