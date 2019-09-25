import 'package:contractor_search/models/UserMessage.dart';
import 'package:contractor_search/models/PushNotification.dart';

class WrappedMessage {
  PushNotification _pushNotification;
  UserMessage _message;

  WrappedMessage(this._pushNotification, this._message);

  UserMessage get message => _message;

  PushNotification get pushNotification => _pushNotification;

  Map<String, dynamic> toJson() =>
      {'notification': _pushNotification, 'data': _message};

  WrappedMessage.fromJson(Map<String, dynamic> json)
      : _pushNotification = PushNotification.fromJson(json['notification']),
        _message = UserMessage.fromJson(json['data']);
}
