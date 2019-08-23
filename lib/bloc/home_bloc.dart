import 'dart:async';

import 'package:contacts_service/contacts_service.dart';

enum NavBarItem { HOME, CONTACTS, PLUS, INBOX, ACCOUNT }

class HomeBloc {
  final StreamController<NavBarItem> _navBarController =
  StreamController<NavBarItem>.broadcast();

  NavBarItem defaultItem = NavBarItem.HOME;

  Stream<NavBarItem> get itemStream => _navBarController.stream;

  void pickItem(int i) {
    switch (i) {
      case 0:
        _navBarController.sink.add(NavBarItem.HOME);
        break;
      case 1:
        _navBarController.sink.add(NavBarItem.CONTACTS);
        break;
      case 2:
          _navBarController.sink.add(NavBarItem.PLUS);
        break;
      case 3:
        _navBarController.sink.add(NavBarItem.INBOX);
        break;
      case 4:
        _navBarController.sink.add(NavBarItem.ACCOUNT);
        break;
    }
  }

  void dispose() {
    _navBarController?.close();
  }

  getContacts() async {
    return ContactsService.getContacts();
  }
}

