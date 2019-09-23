import 'package:contractor_search/model/user.dart';
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

String getInterlocutorName(User user1, User user2, String currentUserId) {
  if (user1.id == currentUserId) {
    return user2.name;
  } else {
    return user1.name;
  }
}

String escapeJsonCharacters(String imageUrlDownload) {
  return imageUrlDownload.replaceAll("?", "%3F");
}

String getFormattedDateTime(DateTime dateTime) {
  return DateFormat("dd/MM/yyyy").format(dateTime);
}
