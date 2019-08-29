class LocationModel {
  LocationModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        city = json['city'];
  
  final int id;
  final String city;
}
