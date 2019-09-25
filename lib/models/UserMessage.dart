import 'package:contractor_search/model/user.dart';

class UserMessage {
  String _channelId;
  User _sharedContact;
  String _message;
  DateTime _timestamp;
  String _messageAuthor;
  String _stringTimestamp;
  bool showUserIcon = true;
  String _imageDownloadUrl;

  UserMessage(this._message, this._timestamp, this._messageAuthor, this._channelId);

  UserMessage.withImage(DateTime timestamp, String imageDownloadUrl,
      String messageAuthor, String channelId) {
    this._timestamp = timestamp;
    this._imageDownloadUrl = imageDownloadUrl;
    this._messageAuthor = messageAuthor;
    this._channelId = channelId;
  }

  UserMessage.withSharedContact(
      DateTime timestamp, String messageAuthor, User user, String channelId) {
    this._timestamp = timestamp;
    this._messageAuthor = messageAuthor;
    this._sharedContact = user;
    this._channelId = channelId;
  }

  User get sharedContact => _sharedContact;

  String get imageDownloadUrl => _imageDownloadUrl;

  String get message => _message;

  String get messageAuthor => _messageAuthor;

  String get stringTimestamp => _stringTimestamp;

  DateTime get timestamp => _timestamp;

  Map<String, dynamic> toJson() => {
        '_channelId': _channelId,
        'message': _message,
        'timestamp': _timestamp.toIso8601String(),
        'messageAuthor': _messageAuthor,
        'imageDownloadUrl': _imageDownloadUrl,
        'sharedContact': _sharedContact
      };

  UserMessage.fromJson(Map<String, dynamic> json)
      : _message = json['message'],
        _timestamp = DateTime.parse(json['timestamp']),
        _stringTimestamp = json['timestamp'],
        _messageAuthor = json['messageAuthor'],
        _imageDownloadUrl = json['imageDownloadUrl'],
        _sharedContact = json['sharedContact'] != null
            ? User.fromJson(json['sharedContact'])
            : null;
}
