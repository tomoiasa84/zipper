import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/model/unjoined_contacts_model.dart';

class SyncContactsModel{
  List<UnjoinedContactsModel> unjoinedContacts;
  List<Contact> existingUsers;
  String countryCode;
  String error;

  SyncContactsModel(this.unjoinedContacts, this.existingUsers, this.countryCode, this.error);
}