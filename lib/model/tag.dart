class Tag {
  Tag.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];

  final int id;
  final String name;
}
