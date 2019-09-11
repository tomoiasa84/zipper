import 'package:contractor_search/model/settings.dart';
import 'package:contractor_search/model/tag.dart';
import 'package:contractor_search/model/thread_message.dart';

import 'card.dart';
import 'location.dart';

class User {
  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        location = json["location"] !=null ? LocationModel.fromJson(json['location']): null,
        phoneNumber = json['phoneNumber'],
        isActive = json['isActive'],
        card = json['cards'] !=null ?(json['cards'] as List)?.map((i)=> Card.fromJson(i))?.toList() : null,
        tags =  json['tags'] !=null ? (json['tags'] as List)?.map((i)=> Tag.fromJson(i))?.toList() : null,
        threadMessages = json['thread_messages'] !=null ? (json['thread_messages'] as List)?.map((i)=> ThreadMessage.fromJson(i))?.toList() : null,
        cardsFeed =json['cards_feed'] !=null ? (json['cards_feed'] as List)?.map((i)=> Card.fromJson(i))?.toList() : null,
        settings = json['settings'] !=null ? (json['settings'] as List)?.map((i)=> Setting.fromJson(i))?.toList(): null;

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
