import 'package:contractor_search/model/card.dart';
import 'package:contractor_search/model/user.dart';

class UserMessage {
  String _clickAction = "FLUTTER_NOTIFICATION_CLICK";
  String _channelId;
  User _sharedContact;
  String _message;
  DateTime _timestamp;
  String _messageAuthor;
  String _stringTimestamp;
  bool showUserIcon = true;
  String _imageDownloadUrl;
  CardModel _cardModel;
  String messageAuthorPicture;

  UserMessage(this._message, this._timestamp, this._messageAuthor,
      this._channelId, this.messageAuthorPicture);

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

  UserMessage.withSharedCard(DateTime timestamp, String messageAuthor,
      CardModel cardModel, String channelId) {
    this._timestamp = timestamp;
    this._messageAuthor = messageAuthor;
    this._cardModel = cardModel;
    this._channelId = channelId;
  }

  CardModel get cardModel => _cardModel;

  User get sharedContact => _sharedContact;

  String get imageDownloadUrl => _imageDownloadUrl;

  String get message => _message;

  String get messageAuthor => _messageAuthor;

  String get stringTimestamp => _stringTimestamp;

  DateTime get timestamp => _timestamp;

  String get channelId => _channelId;

  Map<String, dynamic> toJson() => {
        'channelId': _channelId,
        'message': _message,
        'timestamp': _timestamp.toIso8601String(),
        'messageAuthor': _messageAuthor,
        'messageAuthorPicture': messageAuthorPicture,
        'imageDownloadUrl': _imageDownloadUrl,
        'sharedContact': _sharedContact,
        'click_action': _clickAction,
        'cardModel': _cardModel
      };

  UserMessage.fromJson(Map<String, dynamic> json)
      : _message = json['message'],
        _channelId = json['channelId'],
        messageAuthorPicture = json['messageAuthorPicture'],
        _timestamp = DateTime.parse(json['timestamp']),
        _stringTimestamp = json['timestamp'],
        _messageAuthor = json['messageAuthor'],
        _imageDownloadUrl = json['imageDownloadUrl'],
        _clickAction = json['clickAction'],
        _cardModel = json['cardModel'] != null
            ? CardModel.fromJson(json['cardModel'])
            : null,
        _sharedContact = json['sharedContact'] != null
            ? User.fromJson(json['sharedContact'])
            : null;
}
