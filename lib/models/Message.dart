class Message {
  String _message;
  DateTime _timestamp;
  String _from;

  Message(this._message, this._timestamp, this._from);

  String get stringTimestamp => _timestamp.toIso8601String();

  String get message => _message;

  String get from => _from;

  Map<String, dynamic> toJson() => {
        'message': _message,
        'timestamp': _timestamp.toIso8601String(),
        'from': _from
      };

  Message.fromJson(Map<String, dynamic> json)
      : _message = json['message'],
        _timestamp = json['timestamp'],
        _from = json['from'];
}
