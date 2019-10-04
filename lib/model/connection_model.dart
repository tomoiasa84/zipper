import 'package:contractor_search/model/user.dart';

class Connection {
  Connection.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        originUser = json['originUser'] != null
            ? User.fromJson(json['originUser'])
            : null,
        targetUser = json['targetUser'] != null
            ? User.fromJson(json['targetUser'])
            : null;

  final int id;
  final User originUser;
  final User targetUser;
}
