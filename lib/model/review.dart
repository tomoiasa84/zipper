import 'package:contractor_search/model/tag.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/model/user_tag.dart';

class Review {
  Review.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        author = User.fromJson(json['author']),
        userTag = UserTag.fromJson(json['userTag']),
        stars = json['stars'],
        text = json['text'];

  final int id;
  final User author;
  final UserTag userTag;
  final int stars;
  final String text;

}
