import 'package:contractor_search/model/user.dart';

import 'card.dart';

class Recommand {
  Recommand.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        card = json['card'],
        userAsk = json['uaserAsk'],
        userSend = json['userSend'],
        userRecommand = json['userRecommand'],
        acceptedFlag = json['acceptedFlag'];

  final int id;
  final CardModel card;
  final User userAsk;
  final User userSend;
  final User userRecommand;
  final bool acceptedFlag;
}
