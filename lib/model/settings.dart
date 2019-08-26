class Setting {
  Setting.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        value = json['value'];

  final int id;
  final String name;
  final String value;
}
