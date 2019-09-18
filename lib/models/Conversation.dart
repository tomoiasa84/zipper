import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/LastMessage.dart';

class PubNubConversation {
  String _id;
  String _name;
  String _hashtag;
  String _messagePreview;
  int _timeToken;
  User user1;
  User user2;
  LastMessage _lastMessage;

  PubNubConversation(this._id, this._name, this._hashtag, this._messagePreview,
      this._lastMessage);

  String get id => _id;

  String get messagePreview => _messagePreview;

  String get hashtag => _hashtag;

  String get name => _name;

  int get timeToken => _timeToken;

  LastMessage get lastMessage => _lastMessage;

  PubNubConversation.fromJson(Map<String, dynamic> json)
      : _timeToken = json['timetoken'],
        _lastMessage = json['message'];
}
