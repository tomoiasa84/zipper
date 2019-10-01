import 'package:contractor_search/model/conversation_model.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/model/user_tag.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:intl/intl.dart';

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

String getInterlocutorName(User user1, User user2, String currentUserId) {
  if (user1.id == currentUserId) {
    return user2.name;
  } else {
    return user1.name;
  }
}

String getStringOfChannelIds(List<ConversationModel> listOfConversation) {
  String channelIds = "";

  for (var item in listOfConversation) {
    channelIds = channelIds + item.id.toString() + ",";
  }

  return channelIds;
}

String escapeJsonCharacters(String imageUrlDownload) {
  return imageUrlDownload.replaceAll("?", "%3F");
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
        (currentTime.difference(exactDate).inDays / 7).toString() + 'w';
  }

  return difference;
}

DateTime parseDateFromString(String time) {
  DateFormat dateFormat = DateFormat("EEE MMM dd yyyy HH:mm:ss zzz");
  var date = dateFormat.parse(time);
  return date;
}

String getReviewForMainTag(User user, UserTag mainUserTag) {
  String stars = '';
  user.reviews.forEach((review) {
    if (review.userTag.id == mainUserTag.id) {
      stars = review.stars.toString();
    }
  });
  return stars;
}

UserTag getMainTag(User user) {
  return user.tags.firstWhere((tag) => tag.defaultTag, orElse: () => null);
}