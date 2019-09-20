import 'dart:collection';

import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/models/LastMessage.dart';
import 'package:contractor_search/models/Message.dart';

class BatchHistoryResponse {
  LinkedHashMap _channels;
  int _status;
  bool _error;
  String _errorMessage;

  BatchHistoryResponse(this._channels);

  LinkedHashMap get channels => _channels;

  int get status => _status;

  bool get error => _error;

  String get errorMessage => _errorMessage;

  List<PubNubConversation> get conversations => getConversations(_channels);

  BatchHistoryResponse.fromJson(Map<String, dynamic> json)
      : _channels = json['channels'],
        _status = json['status'],
        _error = json['error'],
        _errorMessage = json['error_message'];

  List<PubNubConversation> getConversations(_channels) {
    var list = List<PubNubConversation>();
    _channels.forEach((k, v) => list.add(_mapConversation(k, v)));
    list.sort((a, b) {
      return b.lastMessage.timeToken.compareTo(a.lastMessage.timeToken);
    });
    return list;
  }

  PubNubConversation _mapConversation(dynamic k, dynamic v) {
    LinkedHashMap hashMap = v[0];

    LastMessage lastMessage = LastMessage(
        hashMap['timetoken'], Message.fromJson(hashMap['message']));

    return PubNubConversation(k.toString(), k.toString(), "", "", lastMessage);
  }
}
