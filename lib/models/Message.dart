class Message {
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

  String get imageDownloadUrl => _imageDownloadUrl;

  String get message => _message;

  String get from => _from;

  String get stringTimestamp => _stringTimestamp;

  Map<String, dynamic> toJson() => {
        'message': _message,
        'timestamp': _timestamp.toIso8601String(),
        'from': _from,
        'imageDownloadUrl': _imageDownloadUrl
      };

  Message.fromJson(Map<String, dynamic> json)
      : _message = json['message'],
        _timestamp = DateTime.parse(json['timestamp']),
        _stringTimestamp = json['timestamp'],
        _from = json['from'],
        _imageDownloadUrl = json['imageDownloadUrl'];
}
