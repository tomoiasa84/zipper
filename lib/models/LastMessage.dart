import 'package:contractor_search/models/Message.dart';

class LastMessage {
  String _timeToken;
  Message _message;

  LastMessage(this._timeToken, this._message);

  String get timeToken => _timeToken;

  Message get message => _message;

  LastMessage.fromJson(Map<String, dynamic> json)
      : _timeToken = json['timetoken'],
        _message =
            json['message'] != null ? Message.fromJson(json['message']) : null;
}
