class Tag {
  Tag.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];

   int id;
  final String name;

  Tag(this.name);


}
