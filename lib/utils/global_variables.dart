import 'package:contractor_search/persistance/repository.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'custom_auth_link.dart';

class GlobalVariable {
  static final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  static HttpLink link =
  HttpLink(uri: 'https://xfriends.azurewebsites.net/graphql');

  static final CustomAuthLink _authLink = CustomAuthLink();

  GraphQLClient client = GraphQLClient(
    cache: InMemoryCache(),
    link: _authLink.concat(link),
  );

  static Repository repository = Repository();
}
