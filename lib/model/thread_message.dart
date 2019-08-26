import 'package:contractor_search/model/recommand.dart';
import 'package:contractor_search/model/user.dart';

import 'message.dart';

class ThreadMessage {
  ThreadMessage.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        users = json['user'],
        messages = json['messages'],
        recommandCard = json['recommandCard'];

  final int id;
  final List<User> users;
  final List<Message> messages;
  final Recommand recommandCard;
}
