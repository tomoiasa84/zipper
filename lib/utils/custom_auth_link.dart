import 'dart:async';

import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graphql/src/link/fetch_result.dart';
import 'package:graphql/src/link/operation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CustomAuthLink extends Link {
  CustomAuthLink()
      : super(request: (
          Operation operation, [
          NextLink forward,
        ]) {
          StreamController<FetchResult> controller;
          Future<void> onListen() async {
            await controller.addStream(
                getRequestStream(controller, forward, operation).asStream());
            await controller.close();
          }

          controller =
              StreamController<FetchResult>.broadcast(onListen: onListen);

          return controller.stream;
        });
}

Future<FetchResult> getRequestStream(StreamController<FetchResult> controller,
    NextLink forward, Operation operation) async {
  String accessToken = await SharedPreferencesHelper.getAccessToken();

  try {
    operation.setContext(<String, Map<String, String>>{
      'headers': {
        'Authorization': 'Bearer $accessToken',
      }
    });
    var mainStream = forward(operation);
    var firstEvent = await whenFirst(mainStream);

    if (firstEvent.errors != null &&
        firstEvent.errors[0]["extensions"]["exception"]["errorInfo"]["code"] ==
            "auth/id-token-expired") {
      var token = await refreshToken(accessToken);

      print("Token refreshed!!!");
      if (token.isNotEmpty) {
        await saveAccessToken(token);
        operation.setContext(<String, Map<String, String>>{
          'headers': {
            'Authorization': 'Bearer $token',
          }
        });
        return whenFirst(forward(operation));
      } else {
        return whenFirst(forward(operation));
      }
    } else {
      return firstEvent;
    }
  } catch (e) {
    return Future.error(e);
  }
}

// ignore: missing_return
Future<T> whenFirst<T>(Stream<T> source) async {
  try {
    await for (T value in source) {
      if (value != null) {
        return value;
      }
    }
  } catch (e) {
    return Future.error(e);
  }
}

Future<String> refreshToken(String accessToken) async {
  FirebaseAuth _auth = FirebaseAuth.instance;

  try {
    final FirebaseUser currentUser = await _auth.currentUser();

    if (currentUser != null && accessToken.isNotEmpty) {
      var token = await currentUser.getIdToken(refresh: true);
      if (token.token != accessToken) {
        return token.token;
      }
    }
    return accessToken;
  } catch (e) {
    return Future.error(e);
  }
}

Future saveAccessToken(String accessToken) async {
  await SharedPreferencesHelper.saveAccessToken(accessToken);
}
