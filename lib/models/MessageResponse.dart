import 'Message.dart';

class MessageResponse {
  List<Message> _messageList;

  MessageResponse(this._messageList);

  List<Message>  get messagesList => _messageList;

  MessageResponse.fromJson(Map<String, dynamic> json)
      : _messageList = json[''];
}
