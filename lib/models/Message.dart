import 'package:contractor_search/model/user.dart';

class Message {
  String _channelId;
  User _sharedContact;
  String _message;
  DateTime _timestamp;
  String _from;
  String _stringTimestamp;
  bool showUserIcon = true;
  String _imageDownloadUrl;

  Message(this._message, this._timestamp, this._from);

  Message.withImage(DateTime timestamp, String imageDownloadUrl, String from) {
    this._timestamp = timestamp;
    this._imageDownloadUrl = imageDownloadUrl;
    this._from = from;
  }

  Message.withSharedContact(DateTime timestamp, String from, User user) {
    this._timestamp = timestamp;
    this._from = from;
    this._sharedContact = user;
  }

  User get sharedContact => _sharedContact;

  String get imageDownloadUrl => _imageDownloadUrl;

  String get message => _message;

  String get from => _from;

  String get stringTimestamp => _stringTimestamp;

  DateTime get timestamp => _timestamp;

  Map<String, dynamic> toJson() => {
        '_channelId': _channelId,
        'message': _message,
        'timestamp': _timestamp.toIso8601String(),
        'from': _from,
        'imageDownloadUrl': _imageDownloadUrl,
        'sharedContact': _sharedContact
      };

  Message.fromJson(Map<String, dynamic> json)
      : _message = json['message'],
        _timestamp = DateTime.parse(json['timestamp']),
        _stringTimestamp = json['timestamp'],
        _from = json['from'],
        _imageDownloadUrl = json['imageDownloadUrl'],
        _sharedContact = json['sharedContact'] != null
            ? User.fromJson(json['sharedContact'])
            : null;
}
