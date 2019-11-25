import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/model/phoneContactInput.dart';
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
  Future<QueryResult> loadContacts(List<String> phoneContacts) async {
    return await _repository.loadContacts(phoneContacts);
  }
  Future<QueryResult> loadAgenda(List<PhoneContactInput> phoneContacts) async {
    return await _repository.loadAgenda(phoneContacts);
  }
  Future<List<PhoneContactInput>> syncContacts(String userId) async {
    QueryResult result = await _repository.getUserByIdWithPhoneNumber(userId);
    print("Hit syncContacs");
    if (result.errors == null) {
      countryCode =
          User.fromJson(result.data['get_user']).phoneNumber.substring(0, 2);

      var contactsResult = await getContacts();
      print("Got contactResult");
      print(contactsResult.length);
      if (contactsResult != null && contactsResult.isNotEmpty) {
        List<PhoneContactInput> phoneContacts = _formatContactsNumber(contactsResult);
        print(phoneContacts.length);
        if (phoneContacts.isNotEmpty) {
          return phoneContacts;
//          var checkResult = await checkContacts(phoneContacts.toSet().toList());
//          if (checkResult.errors == null) {
//            return _groupExistingUsers(checkResult, contactsResult);
//          } else
//            return SyncContactsModel(
//                [], [], countryCode, result.errors[0].message);
        }
        return null;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  List<PhoneContactInput> _formatContactsNumber(Iterable<Contact> contactsResult) {
    List<PhoneContactInput> phoneContacts = [];
    print(contactsResult);
    contactsResult.forEach((item) {
      //print(item.displayName);
      if (item.phones != null && item.phones.toList().isNotEmpty) {
        if (item.phones
            .toList()
            .elementAt(0)
            .value
            .toString()
            .startsWith("+")) {
          phoneContacts.add(PhoneContactInput.fromJson({"name":item.displayName,"phoneNumber":item.phones.toList().elementAt(0).value.replaceAll(new RegExp(r"\s+\b|\b\s"), "")}));
        } else {
          phoneContacts
              .add(PhoneContactInput.fromJson({"name":item.displayName,"phoneNumber":countryCode + item.phones.toList().elementAt(0).value.replaceAll(new RegExp(r"\s+\b|\b\s"), "")}));
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
