import 'package:contacts_service/contacts_service.dart';

  class ContactsBloc {

  void dispose() {
  }

  getContacts() async {
    return ContactsService.getContacts();
  }
}

