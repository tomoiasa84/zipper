import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/model/contact_model.dart';
import 'package:contractor_search/model/formatted_contact_model.dart';
import 'package:contractor_search/model/formatted_contacts.dart';
import 'package:contractor_search/model/sync_contacts_model.dart';
import 'package:contractor_search/model/unjoined_contacts_model.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:country_pickers/countries.dart';
import 'package:country_pickers/country.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:phone_number/phone_number.dart';
import 'package:rxdart/rxdart.dart';

class SyncContactsBloc {
  Country countryCode;

  final _syncContactsFetcher = PublishSubject<SyncContactsModel>();

  Observable<SyncContactsModel> get syncContactsObservable =>
      _syncContactsFetcher.stream;

  Future<Iterable<Contact>> getContacts() async {
    return await Repository().getContacts();
  }

  Future<QueryResult> checkContacts(List<String> phoneContacts) async {
    return await Repository().checkContacts(phoneContacts);
  }

  syncContacts(String userId) async {
    QueryResult result = await Repository().getUserByIdWithPhoneNumber(userId);

    if (result.errors == null) {
      final parsedPhoneNumber = await PhoneNumber.parse(
          User.fromJson(result.data['get_user']).phoneNumber);

      countryCode = countryList.firstWhere(
          (item) => item.phoneCode == parsedPhoneNumber['country_code'],
          orElse: () => null);

      var contactsResult = await getContacts();
      print("Got contactResult");
      print(contactsResult.length);
      if (contactsResult != null && contactsResult.isNotEmpty) {
        FormattedContacts formattedContacts =
            await _formatContactsNumber(contactsResult);
        if (formattedContacts.formattedPhoneNumbers.isNotEmpty) {
          var checkResult = await checkContacts(
              formattedContacts.formattedPhoneNumbers.toSet().toList());
          if (checkResult.errors == null) {
            if (!_syncContactsFetcher.isClosed) {
              _syncContactsFetcher.sink
                  .add(_groupExistingUsers(checkResult, formattedContacts));
            }
          } else {
            if (!_syncContactsFetcher.isClosed) {
              _syncContactsFetcher.sink
                  .add(SyncContactsModel([], [], result.errors[0].message));
            }
          }
        }else {
          if (!_syncContactsFetcher.isClosed) {
            _syncContactsFetcher.sink.add(SyncContactsModel([], [], ""));
          }
        }
      } else {
        if (!_syncContactsFetcher.isClosed) {
          _syncContactsFetcher.sink.add(SyncContactsModel([], [], ""));
        }
      }
    } else {
      if (!_syncContactsFetcher.isClosed) {
        _syncContactsFetcher.sink
            .add(SyncContactsModel([], [], result.errors[0].message));
      }
    }
  }

  Future<FormattedContacts> _formatContactsNumber(
      Iterable<Contact> contactsResult) async {
    List<String> phoneContacts = new List();
    List<FormattedContactModel> formattedContacts = new List();

    for (Contact item in contactsResult) {
      if (item.phones != null && item.phones.toList().isNotEmpty) {
        try {
          if (item.phones.elementAt(0).value.toString().startsWith("+")) {
            phoneContacts.add(item.phones
                .elementAt(0)
                .value
                .toString()
                .replaceAll(RegExp(r"[^\s\w\+]"), '')
                .split(" ")
                .join(""));
            formattedContacts.add(FormattedContactModel(
                item,
                item.phones
                    .elementAt(0)
                    .value
                    .toString()
                    .replaceAll(RegExp(r"[^\s\w\+]"), '')
                    .split(" ")
                    .join("")));
          } else {
            var parsed = await PhoneNumber.parse(
                item.phones
                    .elementAt(0)
                    .value
                    .toString()
                    .replaceAll(RegExp(r"[^\s\w\+]"), '')
                    .split(" ")
                    .join(""),
                region: countryCode.isoCode);
            phoneContacts.add(parsed['e164']
                .replaceAll(RegExp(r"[^\s\w\+]"), '')
                .split(" ")
                .join(""));
            formattedContacts.add(FormattedContactModel(
                item,
                parsed['e164']
                    .replaceAll(RegExp(r"[^\s\w\+]"), '')
                    .split(" ")
                    .join("")));
          }
        } on PlatformException {
          phoneContacts.add("+" +
              item.phones
                  .elementAt(0)
                  .value
                  .toString()
                  .replaceAll(RegExp(r"[^\s\w\+]"), '')
                  .split(" ")
                  .join(""));
          formattedContacts.add(FormattedContactModel(
              item,
              ("+" +
                  item.phones
                      .elementAt(0)
                      .value
                      .toString()
                      .replaceAll(RegExp(r"[^\s\w\+]"), '')
                      .split(" ")
                      .join(""))));
        }
      }
    }
    return FormattedContacts(phoneContacts, formattedContacts);
  }

  SyncContactsModel _groupExistingUsers(
      QueryResult result, FormattedContacts formattedContacts) {
    List<UnjoinedContactsModel> unjoinedContacts = [];
    List<FormattedContactModel> joinedContacts = [];
    final List<Map<String, dynamic>> checkContactsResult =
        result.data['check_contacts'].cast<Map<String, dynamic>>();
    checkContactsResult.forEach((item) {
      ContactModel contactModel = ContactModel.fromJson(item);

      FormattedContactModel contact =
          formattedContacts.formattedContactModelList.firstWhere(
              (formattedContact) =>
                  formattedContact.formattedPhoneNumber == contactModel.number,
              orElse: () => null);
      if (contact != null) if (contactModel.exists) {
        joinedContacts.add(contact);
      } else {
        unjoinedContacts.add(UnjoinedContactsModel(contact, true));
      }
    });
    return SyncContactsModel(unjoinedContacts, joinedContacts, "");
  }

  dispose() {
    _syncContactsFetcher.close();
  }
}
