import 'dart:convert';

import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/bloc/sync_contacts_model.dart';
import 'package:contractor_search/model/contact_model.dart';
import 'package:contractor_search/model/unjoined_contacts_model.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/utils/custom_auth_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SyncContactsBloc {
  void dispose() {}

  static HttpLink link =
      HttpLink(uri: 'https://xfriendstest.azurewebsites.net');

  static final CustomAuthLink _authLink = CustomAuthLink();

  GraphQLClient client = GraphQLClient(
    cache: InMemoryCache(),
    link: _authLink.concat(link),
  );
  String countryCode;

  Future<Iterable<Contact>> getContacts() async {
    return await ContactsService.getContacts();
  }

  Future<QueryResult> checkContacts(List<String> phoneContacts) async {
    var phoneContactsJson = jsonEncode(phoneContacts);

    final QueryResult queryResult = await client.mutate(
      MutationOptions(
        document: '''query{
                    check_contacts(contactsList: $phoneContactsJson){
                      number
                      exists
                    }
                  }''',
      ),
    );

    return queryResult;
  }

  Future<SyncContactsModel> syncContacts(String userId) async {
    final QueryResult result = await client.query(QueryOptions(
      document: '''query{
                     get_user(userId:"$userId"){
                        name
                        firebaseId
                        id
                        phoneNumber
                        isActive
                        location{
                            id
                            city
                        }
                        tags{
                          id
                          user{
                            name
                          }
                        }
                        description
                        cards{
                            text
                        }
                    }
              }''',
    ));

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
            return SyncContactsModel([], [], countryCode,result.errors[0].message);
        }
        return SyncContactsModel([], [], countryCode,"");
      } else {
        return SyncContactsModel([], [], countryCode,"");
      }
    } else {
      return SyncContactsModel([], [], countryCode,result.errors[0].message);
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
              ? (contact.phones.toList().elementAt(0).value ==
                      contactModel.number ||
                  countryCode + contact.phones.toList().elementAt(0).value ==
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
