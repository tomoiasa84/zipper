import 'package:contractor_search/model/thread_message.dart';
import 'package:contractor_search/model/user.dart';

class Message {
  Message.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        text = json['text'],
        messageThread = json['messageThread'],
        from = json['from'];

  final int id;
  final String text;
  final ThreadMessage messageThread;
  final User from;
}
