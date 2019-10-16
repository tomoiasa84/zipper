import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/model/sync_contacts_model.dart';
import 'package:contractor_search/model/contact_model.dart';
import 'package:contractor_search/model/unjoined_contacts_model.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SyncContactsBloc {
  Repository _repository = Repository();
  String countryCode;

  Future<Iterable<Contact>> getContacts() async {
    return await _repository.getContacts();
  }

  Future<QueryResult> checkContacts(List<String> phoneContacts) async {
    return await _repository.checkContacts(phoneContacts);
  }

  Future<SyncContactsModel> syncContacts(String userId) async {
    QueryResult result = await _repository.getUserById(userId);

    if (result.errors == null) {
      countryCode =
          User.fromJson(result.data['get_user']).phoneNumber.substring(0, 2);

      var contactsResult = await getContacts();
      if (contactsResult != null && contactsResult.isNotEmpty) {
        List<String> phoneContacts = _formatContactsNumber(contactsResult);

        if (phoneContacts.isNotEmpty) {
          var checkResult = await checkContacts(phoneContacts.toSet().toList());
          if (checkResult.errors == null) {
            return _groupExistingUsers(checkResult, contactsResult);
          } else
            return SyncContactsModel(
                [], [], countryCode, result.errors[0].message);
        }
        return SyncContactsModel([], [], countryCode, "");
      } else {
        return SyncContactsModel([], [], countryCode, "");
      }
    } else {
      return SyncContactsModel([], [], countryCode, result.errors[0].message);
    }
  }

  List<String> _formatContactsNumber(Iterable<Contact> contactsResult) {
    List<String> phoneContacts = [];
    contactsResult.forEach((item) {
      if (item.phones != null && item.phones.toList().isNotEmpty) {
        if (item.phones
            .toList()
            .elementAt(0)
            .value
            .toString()
            .startsWith("+")) {
          phoneContacts.add(item.phones.toList().elementAt(0).value);
        } else {
          phoneContacts
              .add(countryCode + item.phones.toList().elementAt(0).value);
        }
      }
    });
    return phoneContacts;
  }

  SyncContactsModel _groupExistingUsers(
      QueryResult result, Iterable<Contact> contactsResult) {
    List<UnjoinedContactsModel> unjoinedContacts = [];
    List<Contact> joinedContacts = [];
    final List<Map<String, dynamic>> checkContactsResult =
        result.data['check_contacts'].cast<Map<String, dynamic>>();
    checkContactsResult.forEach((item) {
      ContactModel contactModel = ContactModel.fromJson(item);

      Contact contact = contactsResult.firstWhere(
          (contact) => (contact.phones != null &&
                  contact.phones.toList().isNotEmpty)
              ? (contact.phones.toList().elementAt(0).value.replaceAll(new RegExp(r"\s+\b|\b\s"), "") ==
                      contactModel.number.replaceAll(new RegExp(r"\s+\b|\b\s"), "") ||
                  countryCode + contact.phones.toList().elementAt(0).value.replaceAll(new RegExp(r"\s+\b|\b\s"), "") ==
                      contactModel.number)
              : false,
          orElse: () => null);
      if (contact != null) if (contactModel.exists) {
        joinedContacts.add(contact);
      } else {
        unjoinedContacts.add(UnjoinedContactsModel(contact, true));
      }
    });
    return SyncContactsModel(unjoinedContacts, joinedContacts, countryCode, "");
  }
}
