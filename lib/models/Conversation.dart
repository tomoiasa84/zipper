class Conversation {
  String _name;
  String _hashtag;
  String _messagePreview;

  Conversation(this._name, this._hashtag, this._messagePreview);

  String get messagePreview => _messagePreview;

  String get hashtag => _hashtag;

  String get name => _name;
}
