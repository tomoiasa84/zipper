class PushNotification {
  String _title;
  String _body;

  PushNotification(this._title, this._body);

  Map<String, dynamic> toJson() => {'title': _title, 'body': _body};

  PushNotification.fromJson(Map<String, dynamic> json)
      : _title = json['title'],
        _body = json['body'];
}
