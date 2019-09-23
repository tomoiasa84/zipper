import 'package:contractor_search/models/Message.dart';
import 'package:contractor_search/models/PushNotification.dart';

class WrappedMessage {
  PushNotification _pushNotification;
  Message _message;

  WrappedMessage(this._pushNotification, this._message);

  Map<String, dynamic> toJson() =>
      {'notification': _pushNotification, 'data': _message};

  WrappedMessage.fromJson(Map<String, dynamic> json)
      : _pushNotification = PushNotification.fromJson(json['notification']),
        _message = Message.fromJson(json['data']);
}
