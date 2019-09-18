class SharedContact {
  String _name;
  String _hashtag;
  double _stars;
  String _phoneNumber;

  SharedContact(this._name, this._hashtag, this._stars, this._phoneNumber);

  String get phoneNumber => _phoneNumber;

  double get stars => _stars;

  String get hashtag => _hashtag;

  String get name => _name;
}
