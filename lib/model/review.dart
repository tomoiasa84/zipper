import 'package:contractor_search/model/tag.dart';
import 'package:contractor_search/model/user.dart';

class Review{

  Review.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        author = User.fromJson(json['author']),
        userTag = Tag.fromJson(json['userTag']),
        stars = json['stars'],
        text = json['text'];

   final int id;
   final User author;
   Tag userTag;
   final int stars;
   final String text;

  Review(this.id, this.author, this.stars, this.text);

}