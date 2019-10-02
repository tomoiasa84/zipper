import 'package:contractor_search/model/review.dart';
import 'package:contractor_search/model/tag.dart';
import 'package:contractor_search/model/user.dart';

class UserTag {
  UserTag.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        user = json['user'] != null ? User.fromJson(json['user']) : null,
        tag = json['tag'] != null ? Tag.fromJson(json['tag']) : null,
        reviews = json['reviews'] != null
            ? (json['reviews'] as List)
                ?.map((i) => Review.fromJson(i))
                ?.toList()
            : null,
        score = json['score'],
        defaultTag = json['default'];

  final int id;
  final User user;
  final Tag tag;
  final List<Review> reviews;
  final int score;
  final bool defaultTag;
}
