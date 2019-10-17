import 'package:contractor_search/models/UserMessage.dart';

class LastMessage {
  String _timeToken;
  UserMessage _message;
  bool backendMessage = false;
  String channelId;
  String timestamp;
  int cardId;
  String conversationTitle;
  String conversationPreview;

  LastMessage(this._timeToken, this._message);

  String get timeToken => _timeToken;

  UserMessage get message => _message;

  LastMessage.fromJson(Map<String, dynamic> json)
      : _timeToken = json['timetoken'],
        backendMessage = json['backendMessage'],
        channelId = json['channelId'],
        timestamp = json['timestamp'],
        cardId = json['cardId'],
        conversationTitle = json['conversationTitle'],
        conversationPreview = json['conversationPreview'],
        _message = json['message'] != null
            ? UserMessage.fromJson(json['message'])
            : null;
}
