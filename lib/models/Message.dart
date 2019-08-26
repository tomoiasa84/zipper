class Message {
  String _message;
  DateTime _timestamp;
  bool _messageAuthorIsCurrentUser;

  Message(this._message, this._timestamp, this._messageAuthorIsCurrentUser);

  bool get messageAuthorIsCurrentUser => _messageAuthorIsCurrentUser;

  DateTime get timestamp => _timestamp;

  String get message => _message;
}
