import 'package:contractor_search/model/recommand.dart';
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
        recommendsCount = json['recommandsCount'],
        recommendsList = json['recommandsList'] != null
            ? (json['recommandsList'] as List)?.map((i) => Recommend.fromJson(i))?.toList()
            : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'postedBy': postedBy,
        'searchFor': searchFor,
        'createdAt': createdAt,
        'text': text,
        'recommendsCount': recommendsCount,
        'recommendsList': recommendsList,
      };

  final int id;
  final User postedBy;
  final Tag searchFor;
  final String createdAt;
  final String text;
  final int recommendsCount;
  final List<Recommend> recommendsList;
}
