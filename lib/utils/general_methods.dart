import 'package:contractor_search/layouts/authentication_screen.dart';
import 'package:contractor_search/model/conversation_model.dart';
import 'package:contractor_search/model/review.dart';
import 'package:contractor_search/model/tag.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/model/user_tag.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'global_variables.dart';

String validatePhoneNumber(String value, String validationMessage) {
  final RegExp phoneExp =
      RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');
  if (value.length == 12 && phoneExp.hasMatch(value)) {
    return null;
  } else
    return validationMessage;
}

getInitials(String name) {
  if (name != null) {
    var n = name.split(" "), it = "", i = 0;
    int counter = n.length > 2 ? 2 : n.length;
    while (i < counter) {
      if (n[i].isNotEmpty) {
        it += n[i][0];
      }
      i++;
    }
    return (it.toUpperCase());
  } else
    return "";
}

Future<String> getCurrentUserId() async {
  return await SharedPreferencesHelper.getCurrentUserId();
}

User getInterlocutorFromConversation(
    User user1, User user2, String currentUserId) {
  if (user1.id == currentUserId) {
    return user2;
  } else {
    return user1;
  }
}

User getCurrentUserFromConversation(
    User user1, User user2, String currentUserId) {
  if (user1.id == currentUserId) {
    return user1;
  } else {
    return user2;
  }
}

String getReviewQualifier(Review review) {
  switch (review.stars) {
    case 0:
      return 'veryPoor';
      break;
    case 1:
      return 'veryPoor';
      break;
    case 2:
      return 'poor';
      break;
    case 3:
      return 'good';
      break;
    case 4:
      return 'veryGood';
      break;
    case 5:
      return 'excellent';
      break;
    default:
      return 'excellent';
  }
}

String getStringOfChannelIds(List<ConversationModel> listOfConversation) {
  String channelIds = "";

  for (var item in listOfConversation) {
    channelIds = channelIds + item.id.toString() + ",";
  }

  return channelIds;
}

String escapeJsonCharacters(String myString) {
  var string = myString.replaceAll("#", "%23");
  return string.replaceAll("?", "%3F");
}

String removeMultilineCharacters(String text){
  return text.replaceAll("\n", " ");
}

String getTimeDifference(String time) {
  DateTime date = parseDateFromString(time);

  Duration duration = date.timeZoneOffset;
  DateTime currentTime = DateTime.now();
  String difference;
  DateTime exactDate = date.add(duration);

  if (currentTime.difference(exactDate).inSeconds < 60) {
    difference = (currentTime.difference(exactDate).inSeconds).toString() + "s";
  } else if (currentTime.difference(exactDate).inSeconds > 60 &&
      currentTime.difference(exactDate).inMinutes < 60) {
    difference = (currentTime.difference(exactDate).inMinutes).toString() + "m";
  } else if (currentTime.difference(exactDate).inMinutes >= 60 &&
      currentTime.difference(exactDate).inHours < 24) {
    difference = (currentTime.difference(exactDate).inHours).toString() + "h";
  } else if (currentTime.difference(exactDate).inHours >= 24 &&
      currentTime.difference(exactDate).inDays < 7) {
    difference = (currentTime.difference(exactDate).inDays).toString() + "d";
  } else if (currentTime.difference(exactDate).inDays >= 7 &&
      currentTime.difference(exactDate).inDays < 52) {
    difference =
        (currentTime.difference(exactDate).inDays ~/ 7).toString() + 'w';
  }

  return difference;
}

DateTime parseDateFromString(String time) {
  DateFormat dateFormat = DateFormat("EEE MMM dd yyyy HH:mm:ss zzz");
  var date = dateFormat.parse(time);
  return date;
}

UserTag getMainTag(User user) {
  return user.tags.firstWhere((tag) => tag.defaultTag, orElse: () => null);
}

int getScoreForSearchedTag(List<UserTag> tags, Tag searchedTag) {
  UserTag tag = tags.firstWhere((tag) => tag.tag.id == searchedTag.id,
      orElse: () => null);
  if (tag != null) {
    if (tag.reviews.isEmpty) {
      return -1;
    } else {
      return tag.score;
    }
  } else {
    return -1;
  }
}

void logout(bool showExpiredSessionMessage){
  GlobalVariable.navigatorKey.currentState.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => AuthenticationScreen(showExpiredSessionMessage: showExpiredSessionMessage)),
          (Route<dynamic> route) => false);
}
