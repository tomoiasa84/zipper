import 'package:contractor_search/models/UserMessage.dart';

class LastMessage {
  String _timeToken;
  UserMessage _message;

  LastMessage(this._timeToken, this._message);

  String get timeToken => _timeToken;

  UserMessage get message => _message;

  LastMessage.fromJson(Map<String, dynamic> json)
      : _timeToken = json['timetoken'],
        _message =
            json['message'] != null ? UserMessage.fromJson(json['message']) : null;
}
