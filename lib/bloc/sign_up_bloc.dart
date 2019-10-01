import 'package:contractor_search/model/location.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SignUpBloc {
  Repository _repository = Repository();

  Future<List<LocationModel>> getLocations() async {
    QueryResult data = await _repository.getLocations();

    final List<Map<String, dynamic>> locations =
    data.data['get_locations'].cast<Map<String, dynamic>>();
    List<LocationModel> list = [];
    locations.forEach((location) => list.add(LocationModel.fromJson(location)));
    return list;
  }
}
