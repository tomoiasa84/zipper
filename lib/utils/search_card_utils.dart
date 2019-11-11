import 'package:auto_size_text/auto_size_text.dart';
import 'package:contractor_search/layouts/user_details_screen.dart';
import 'package:contractor_search/model/card.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:flutter/material.dart';

import 'general_methods.dart';

class SearchCard extends SearchDelegate<String> {
  List<CardModel> _cards = [];
  Function _onTagTapAction;
  Function _onSendInChatTapAction;
  String _userActionText;
  String _sendInChatText;

  SearchCard(this._cards, this._onTagTapAction, this._onSendInChatTapAction,
      this._userActionText, this._sendInChatText);

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
        ? _cards
        : _cards.where((card) =>
            card.searchFor.name.toLowerCase().startsWith(query.toLowerCase()));

    return ListView.builder(
        itemCount: suggestionList.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          CardModel card = suggestionList.elementAt(index);
          return Container(
              margin: EdgeInsets.only(
                  top: (index == 0) ? 16.0 : 0.0,
                  bottom: (index == suggestionList.length - 1) ? 16.0 : 0.0,
                  left: 16.0,
                  right: 16.0),
              child: _buildCardItem(context, card));
        });
  }

  Widget _buildCardItem(BuildContext context, CardModel card) {
    return GestureDetector(
      onTap: () {
        close(context, null);
        _onTagTapAction(card);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Stack(
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildCardText(context, card),
                  _buildCreatedAtInfo(context, card)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row _buildCardText(BuildContext context, CardModel card) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          child: card.postedBy.profilePicUrl == null ||
                  card.postedBy.profilePicUrl.isEmpty
              ? Text(
                  card.postedBy.name.startsWith('+')
                      ? '+'
                      : getInitials(card.postedBy.name),
                  style: TextStyle(color: ColorUtils.darkerGray))
              : null,
          backgroundImage: card.postedBy.profilePicUrl != null &&
                  card.postedBy.profilePicUrl.isNotEmpty
              ? NetworkImage(card.postedBy.profilePicUrl)
              : null,
          backgroundColor: ColorUtils.lightLightGray,
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        close(context, null);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    UserDetailsScreen(user: card.postedBy)));
                      },
                      child: Text(card.postedBy.name,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Text(_userActionText,
                        style: TextStyle(color: ColorUtils.darkerGray))
                  ],
                ),
                Text(
                  "#" + card.searchFor.name,
                  style: TextStyle(
                      color: ColorUtils.orangeAccent,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Padding _buildCreatedAtInfo(BuildContext context, CardModel card) {
    String difference = getTimeDifference(card.createdAt);
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Image.asset('assets/images/ic_access_time.png'),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 8.0),
                  child: AutoSizeText(
                    difference + ' ago',
                    style: TextStyle(color: ColorUtils.darkerGray),
                  ),
                ),
                Image.asset('assets/images/ic_replies_gray.png'),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 8.0),
                  child: AutoSizeText(
                    card.recommendsCount.toString(),
                    style: TextStyle(color: ColorUtils.darkerGray),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              close(context, null);
              _onSendInChatTapAction(card);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                AutoSizeText(
                  _sendInChatText,
                  style: TextStyle(
                      fontSize: 14,
                      color: ColorUtils.orangeAccent,
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Icon(
                    Icons.send,
                    color: ColorUtils.orangeAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
