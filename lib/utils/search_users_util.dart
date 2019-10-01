import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:flutter/material.dart';

import 'general_methods.dart';

class UserSearch extends SearchDelegate<String> {
  List<User> _users = [];
  Function onTapAction;

  UserSearch(this._users, this.onTapAction);

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
        ? _users
        : _users.where(
            (user) => user.name.toLowerCase().startsWith(query.toLowerCase()));

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          showResults(context);
          close(context, null);
          onTapAction(_users.elementAt(index));
        },
        leading: Container(
          width: 32,
          height: 32,
          decoration: new BoxDecoration(
              shape: BoxShape.circle,
              image: new DecorationImage(
                  fit: BoxFit.cover,
                  image: new NetworkImage("https://i.imgur.com/BoN9kdC.png"))),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RichText(
              text: TextSpan(
                  text: suggestionList
                      .elementAt(index)
                      .name
                      .substring(0, query.length),
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                        text: suggestionList
                            .elementAt(index)
                            .name
                            .substring(query.length),
                        style: TextStyle(color: Colors.grey))
                  ]),
            ),
            Text(
              getMainTag(_users.elementAt(index)) != null
                  ? '#' + getMainTag(_users.elementAt(index)).tag.name
                  : '',
              style: TextStyle(color: ColorUtils.orangeAccent, fontSize: 12.0),
            )
          ],
        ),
      ),
      itemCount: suggestionList.length ?? 0,
    );
  }
}
