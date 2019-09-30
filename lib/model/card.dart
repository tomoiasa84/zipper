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
        text = json['text'],
        recommends = json['recommands'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'postedBy': postedBy,
        'searchFor': searchFor,
        'createdAt': createdAt,
        'text': text,
        'recommands': recommends,
      };

  final int id;
  final User postedBy;
  final Tag searchFor;
  final String createdAt;
  final String text;
  final int recommends;
}
