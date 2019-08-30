import 'package:contractor_search/resources/string_utils.dart';

String validatePhoneNumber(String value) {
  final RegExp phoneExp =
  RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');
  if (value.length == 12 && phoneExp.hasMatch(value)) {
    return null;
  } else
    return Strings.phoneNumberValidation;
}

getInitials(String name) {
  var n = name.split(" "), it = "", i = 0;
  int counter = n.length > 2 ? 2 : n.length;
  while (i < counter) {
    it += n[i][0];
    i++;
  }
  return (it.toUpperCase());
}