import 'package:contacts_service/contacts_service.dart';

class FormattedContactModel {
  Contact contact;
  String formattedPhoneNumber;

  FormattedContactModel(this.contact, this.formattedPhoneNumber);

  bool isReadyForSync() =>
      this != null &&
      this.formattedPhoneNumber != null &&
      this.formattedPhoneNumber.isNotEmpty;
}
