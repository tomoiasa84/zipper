import 'package:contractor_search/model/tag.dart';
import 'package:contractor_search/model/user.dart';

class Card {
  Card.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        postedBy = json['postedBy'],
        searchFor = json['searchFor'],
        createdAt = json['createdAt'],
        text = json['text'];

  final int id;
  final User postedBy;
  final Tag searchFor;
  final String createdAt;
  final String text;
}