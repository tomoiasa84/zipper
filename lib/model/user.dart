import 'package:contractor_search/model/settings.dart';
import 'package:contractor_search/model/tag.dart';
import 'package:contractor_search/model/thread_message.dart';

import 'card.dart';
import 'location.dart';

class User {
  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        location = json['location'],
        phoneNumber = json['phoneNumber'],
        isActive = json['isActive'],
        card = json['card'],
        tags = json['tags'],
        threadMessages = json['threadMessage'],
        cardsFeed = json['cardsFeed'],
        settings = json['settings'];

  final String id;
  final String name;
  final LocationModel location;
  final String phoneNumber;
  final bool isActive;
  final List<Card> card;
  final List<Tag> tags;
  final List<ThreadMessage> threadMessages;
  final List<Card> cardsFeed;
  final List<Setting> settings;
}
