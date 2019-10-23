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
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = "";
          }
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
          onTapAction(suggestionList.elementAt(index));
        },
        leading: Container(
          width: 32,
          height: 32,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            child: suggestionList.elementAt(index).profilePicUrl == null
                ? Text(getInitials(suggestionList.elementAt(index).name),
                    style: TextStyle(color: ColorUtils.darkerGray))
                : null,
            backgroundImage: suggestionList.elementAt(index).profilePicUrl != null
                ? NetworkImage(suggestionList.elementAt(index).profilePicUrl)
                : null,
            backgroundColor: ColorUtils.lightLightGray,
          ),
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
              getMainTag(suggestionList.elementAt(index)) != null
                  ? '#' + getMainTag(suggestionList.elementAt(index)).tag.name
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
