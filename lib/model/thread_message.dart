import 'package:contractor_search/model/recommand.dart';
import 'package:contractor_search/model/user.dart';

import 'message.dart';

class ThreadMessage {
  ThreadMessage.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        users =  json['users'] !=null ? (json['users'] as List)?.map((i)=> User.fromJson(i))?.toList(): null,
        messages = json['messages'] !=null ? (json['messages'] as List)?.map((i)=> Message.fromJson(i))?.toList() : null,
        recommandCard = json['recommandCard'];

  final int id;
  final List<User> users;
  final List<Message> messages;
  final Recommand recommandCard;
}
