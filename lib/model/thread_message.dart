import 'package:contractor_search/model/recommand.dart';
import 'package:contractor_search/model/user.dart';

import 'message.dart';

class ThreadMessage {
  ThreadMessage.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        users = (json['users'] as List)?.map((i)=> User.fromJson(i))?.toList(),
        messages = (json['messages'] as List)?.map((i)=> Message.fromJson(i))?.toList(),
        recommandCard = json['recommandCard'];

  final int id;
  final List<User> users;
  final List<Message> messages;
  final Recommand recommandCard;
}
