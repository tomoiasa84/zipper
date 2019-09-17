import 'dart:async';

import 'package:contacts_service/contacts_service.dart';

enum NavBarItem { HOME, CONTACTS, PLUS, INBOX, ACCOUNT }

class HomeBloc {

  getContacts() async {
    return ContactsService.getContacts();
  }
}

