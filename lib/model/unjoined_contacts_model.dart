import 'package:contractor_search/model/formatted_contact_model.dart';

class UnjoinedContactsModel {
  FormattedContactModel contact;
  bool selected;

  UnjoinedContactsModel(this.contact, this.selected);

  bool isReadyForSync() => this != null && this.selected && this.contact != null;
}
