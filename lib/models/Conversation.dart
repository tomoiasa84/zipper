import 'package:contractor_search/models/LastMessage.dart';

class Conversation {
  String _id;
  String _name;
  String _hashtag;
  String _messagePreview;
  int _timeToken;
  LastMessage _lastMessage;

  Conversation(this._id, this._name, this._hashtag, this._messagePreview,
      this._lastMessage);

  String get id => _id;

  String get messagePreview => _messagePreview;

  String get hashtag => _hashtag;

  String get name => _name;

  int get timeToken => _timeToken;

  LastMessage get lastMessage => _lastMessage;

  Conversation.fromJson(Map<String, dynamic> json)
      : _timeToken = json['timetoken'],
        _lastMessage = json['message'];
}
