import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/model/user_tag.dart';
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
        : _users.where((user) {
            UserTag mainTag = getMainTag(user);
            bool containsMainTag = mainTag != null
                ? mainTag.tag.name.toLowerCase().contains(query.toLowerCase())
                : false;
            return user.name.toLowerCase().contains(query.toLowerCase()) ||
                containsMainTag;
          });

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
            child: suggestionList.elementAt(index).profilePicUrl == null ||
                    suggestionList.elementAt(index).profilePicUrl.isEmpty
                ? Text(
                    suggestionList.elementAt(index).name.contains('+')
                        ? '+'
                        : getInitials(suggestionList.elementAt(index).name),
                    style: TextStyle(color: ColorUtils.darkerGray))
                : null,
            backgroundImage: suggestionList.elementAt(index).profilePicUrl !=
                        null &&
                    suggestionList.elementAt(index).profilePicUrl.isNotEmpty
                ? NetworkImage(suggestionList.elementAt(index).profilePicUrl)
                : null,
            backgroundColor: ColorUtils.getColorForName(
                suggestionList.elementAt(index).name),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              suggestionList.elementAt(index).name,
              style: TextStyle(
                  color: ColorUtils.darkerGray, fontWeight: FontWeight.bold),
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
