import 'dart:developer';

import 'package:contractor_search/model/conversation_model.dart';
import 'package:contractor_search/model/settings.dart';
import 'package:contractor_search/model/user_tag.dart';

import 'card.dart';
import 'location.dart';

class User {
  Map<String, dynamic> toJson() => {
        'id': id,
        'firebaseId': firebaseId,
        'name': name,
        'location': location,
        'description': description,
        'phoneNumber': phoneNumber,
        'isActive': isActive
      };

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        firebaseId = json['firebaseId'],
        name = json['name'],
        location = json["location"] != null
            ? LocationModel.fromJson(json['location'])
            : null,
        phoneNumber = json['phoneNumber'],
        isActive = json['isActive'],
        cards = json['cards'] != null
            ? (json['cards'] as List)
                ?.map((i) => CardModel.fromJson(i))
                ?.toList()
            : null,
        tags = json['tags'] != null
            ? (json['tags'] as List)?.map((i) => UserTag.fromJson(i))?.toList()
            : null,
        conversations = json['conversations'] != null
            ? (json['conversations'] as List)
                ?.map((i) => ConversationModel.fromJson(i))
                ?.toList()
            : null,
        connections = json['connections'] != null
            ? (json['connections'] as List)
                ?.map((i) => User.fromJson(i))
                ?.toList()
            : null,
        cardsFeed = json['cards_feed'] != null
            ? (json['cards_feed'] as List)
                ?.map((i) => CardModel.fromJson(i))
                ?.toList()
            : null,
        settings = json['settings'] != null
            ? (json['settings'] as List)
                ?.map((i) => Setting.fromJson(i))
                ?.toList()
            : null,
        description = json['description'];

  final String id;
  final String firebaseId;
  final String name;
  final LocationModel location;
  final String description;
  final String phoneNumber;
  final bool isActive;
  final List<ConversationModel> conversations;
  final List<User> connections;
  final List<CardModel> cards;
  final List<UserTag> tags;
  final List<CardModel> cardsFeed;
  final List<Setting> settings;
}
