import 'package:contractor_search/model/conversation_model.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/LastMessage.dart';

class PubNubConversation {
  String _id;
  String _name;
  String _hashTag;
  String _messagePreview;
  int _timeToken;
  User _user1;
  User _user2;
  LastMessage _lastMessage;
  bool read = true;

  PubNubConversation(this._id, this._name, this._hashTag, this._messagePreview,
      this._lastMessage);

  PubNubConversation.fromConversation(ConversationModel conversationModel) {
    this._id = conversationModel.id;
    this._user1 = conversationModel.user1;
    this._user2 = conversationModel.user2;
  }

  set user1(User value) {
    _user1 = value;
  }

  User get user1 => _user1;

  String get id => _id;

  String get messagePreview => _messagePreview;

  String get hashTag => _hashTag;

  String get name => _name;

  int get timeToken => _timeToken;

  LastMessage get lastMessage => _lastMessage;

  Map<String, dynamic> toJson() => {'id': id, 'user1': _user1, 'user2': _user2};

  PubNubConversation.fromJson(Map<String, dynamic> json)
      : _timeToken = json['timetoken'],
        _lastMessage = json['message'];

  User get user2 => _user2;

  set user2(User value) {
    _user2 = value;
  }
}
