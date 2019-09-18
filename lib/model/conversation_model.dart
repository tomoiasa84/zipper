import 'package:contractor_search/model/user.dart';

class ConversationModel{
  ConversationModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        user1 = User.fromJson(json['user1']),
        user2 = User.fromJson(json['user2']);

  final String id;
  final User user1;
  final User user2;
}