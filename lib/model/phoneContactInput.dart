class PhoneContactInput {
  Map<String, dynamic> toJson() => {
    'name': name,
    'phoneNumber': phoneNumber
  };

  PhoneContactInput.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        phoneNumber = json['phoneNumber'];

  String name;
  String phoneNumber;
}