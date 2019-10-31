import 'dart:developer';

import 'package:contractor_search/model/conversation_model.dart';
import 'package:contractor_search/model/review.dart';
import 'package:contractor_search/model/settings.dart';
import 'package:contractor_search/model/user_tag.dart';

import 'card.dart';
import 'connection_model.dart';
import 'location.dart';

class User {
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'isActive': isActive,
        'tags': tags,
        'profileURL': profilePicUrl
      };

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        firebaseId = json['firebaseId'],
        profilePicUrl = json['profileURL'],
        name = json['name'],
        location = json['location'] != null
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
                ?.map((i) => Connection.fromJson(i))
                ?.toList()
            : null,
        cardsConnections = json['cardsConnections'] != null
            ? (json['cardsConnections'] as List)
                ?.map((i) => CardModel.fromJson(i))
                ?.toList()
            : null,
        settings = json['settings'] != null
            ? (json['settings'] as List)
                ?.map((i) => Setting.fromJson(i))
                ?.toList()
            : null,
        reviews = json['reviews'] != null
            ? (json['reviews'] as List)
                ?.map((i) => Review.fromJson(i))
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
   List<Connection> connections;
  List<CardModel> cards;
  final List<UserTag> tags;
  final List<CardModel> cardsConnections;
  final List<Review> reviews;
  final List<Setting> settings;
  final String profilePicUrl;
}
