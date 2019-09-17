class ContactModel {
  ContactModel.fromJson(Map<String, dynamic> json)
      : number = json['number'],
        exists = json['exists'];

  final String number;
  final bool exists;
}