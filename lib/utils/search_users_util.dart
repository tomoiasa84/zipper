import 'package:contractor_search/model/user.dart';
import 'package:flutter/material.dart';

class UserSearch extends SearchDelegate<String> {
  Iterable<User> _recentSearchedUsers = [];
  List<User> _users = [];

  UserSearch(this._users);

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
        ? _recentSearchedUsers
        : _users.where(
            (user) => user.name.toLowerCase().startsWith(query.toLowerCase()));

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          showResults(context);
        },
        leading: Icon(Icons.contacts),
        title: RichText(
          text: TextSpan(
              text: suggestionList
                  .elementAt(index)
                  .name
                  .substring(0, query.length),
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                    text: suggestionList
                        .elementAt(index)
                        .name
                        .substring(query.length),
                    style: TextStyle(color: Colors.grey))
              ]),
        ),
      ),
      itemCount: suggestionList.length ?? 0,
    );
  }
}
