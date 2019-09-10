class Message {
  String _message;
  DateTime _timestamp;
  String _from;
  String _stringTimestamp;

  Message(this._message, this._timestamp, this._from);

  String get message => _message;

  String get from => _from;

  String get stringTimestamp => _stringTimestamp;

  Map<String, dynamic> toJson() => {
        'message': _message,
        'timestamp': _timestamp.toIso8601String(),
        'from': _from
      };

  Message.fromJson(Map<String, dynamic> json)
      : _message = json['message'],
        _timestamp = DateTime.parse(json['timestamp']),
        _stringTimestamp = json['timestamp'],
        _from = json['from'];
}
