import 'package:contractor_search/model/tag.dart';
import 'package:contractor_search/model/user.dart';

class CardModel {
  CardModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        postedBy =
            json['postedBy'] != null ? User.fromJson(json['postedBy']) : null,
        searchFor =
            json['searchFor'] != null ? Tag.fromJson(json['searchFor']) : null,
        createdAt = json['createdAt'],
        text = json['text'];

  final int id;
  final User postedBy;
  final Tag searchFor;
  final String createdAt;
  final String text;
}
