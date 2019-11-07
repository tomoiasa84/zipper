import 'package:contractor_search/model/formatted_contact_model.dart';
import 'package:contractor_search/model/unjoined_contacts_model.dart';

class SyncContactsModel {
  List<UnjoinedContactsModel> unjoinedContacts;
  List<FormattedContactModel> existingUsers;
  String error;

  SyncContactsModel(this.unjoinedContacts, this.existingUsers, this.error);
}
