import 'package:contractor_search/model/user.dart';

import 'card.dart';

class Recommend {
  Map<String, dynamic> toJson() => {
        'id': id,
        'card': card,
        'userAsk': userAsk,
        'userSend': userSend,
        'userRecommand': userRecommend,
        'acceptedFlag': acceptedFlag,
      };

  Recommend.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        card = json['card'] != null ? CardModel.fromJson(json['card']) : null,
        userAsk =
            json['userAsk'] != null ? User.fromJson(json['userAsk']) : null,
        userSend =
            json['userSend'] != null ? User.fromJson(json['userSend']) : null,
        userRecommend = json['userRecommand'] != null
            ? User.fromJson(json['userRecommand'])
            : null,
        acceptedFlag = json['acceptedFlag'];

  final int id;
  final CardModel card;
  final User userAsk;
  final User userSend;
  final User userRecommend;
  final bool acceptedFlag;
}
