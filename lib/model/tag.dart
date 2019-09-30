class Tag {
  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  Tag.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];

  int id;
  final String name;

  Tag(this.name);
}
