import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

class ContactsSearch extends SearchDelegate<String> {
  Iterable<Contact> _recentSearchedContacts = [];
  Iterable<Contact> _contacts = [];

  ContactsSearch(this._contacts);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? _recentSearchedContacts
        : _contacts.where((contact) =>
        contact.displayName.toLowerCase().startsWith(query.toLowerCase()));

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: (){showResults(context);},
        leading: Icon(Icons.contacts),
        title: RichText(
          text: TextSpan(
              text: suggestionList
                  .elementAt(index)
                  .displayName
                  .substring(0, query.length),
              style:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                    text: suggestionList
                        .elementAt(index)
                        .displayName
                        .substring(query.length),
                    style: TextStyle(color: Colors.grey))
              ]),
        ),
      ),
      itemCount: suggestionList.length ?? 0,
    );
  }
}
