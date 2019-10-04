import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/model/user_tag.dart';

class Review {
  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author,
        'userTag': userTag,
        'stars': stars,
        'text': text
      };

  Review.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        author = json['author'] != null ? User.fromJson(json['author']) : null,
        userTag =
            json['userTag'] != null ? UserTag.fromJson(json['userTag']) : null,
        stars = json['stars'],
        text = json['text'];

  final int id;
  final User author;
  final UserTag userTag;
  final int stars;
  final String text;
}
