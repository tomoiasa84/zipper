import 'package:contractor_search/model/user.dart';

class ConversationModel {
  ConversationModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        user1 = json['user1'] != null ? User.fromJson(json['user1']) : null,
        user2 = json['user2'] != null ? User.fromJson(json['user2']) : null;

  final String id;
  final User user1;
  final User user2;
}
