import 'package:contractor_search/bloc/recommend_friend_bloc.dart';
import 'package:contractor_search/model/card.dart';
import 'package:contractor_search/model/recommand.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PnGCM.dart';
import 'package:contractor_search/models/PushNotification.dart';
import 'package:contractor_search/models/UserMessage.dart';
import 'package:contractor_search/models/WrappedMessage.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/custom_dialog.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'chat_screen.dart';

class RecommendFriendScreen extends StatefulWidget {
  final CardModel card;

  const RecommendFriendScreen({Key key, this.card}) : super(key: key);

  @override
  RecommendFriendScreenState createState() => RecommendFriendScreenState();
}

class RecommendFriendScreenState extends State<RecommendFriendScreen> {
  List<User> usersWithSearchedTag = [];
  RecommendFriendBloc _recommendBloc;
  bool _saving = false;

  var selectedUserIndex = -1;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() {
    _recommendBloc = RecommendFriendBloc();
    setState(() {
      _saving = true;
    });
    _recommendBloc.getCurrentUserWithConnections().then((result) {
      if (result.errors == null && mounted) {
        User currentUser = User.fromJson(result.data['get_user']);
        if (currentUser != null) {
          setState(() {
            currentUser.connections.forEach((connection) {
              if (hasSearchedTag(connection.targetUser) &&
                  connection.targetUser.id != widget.card.postedBy.id) {
                usersWithSearchedTag.add(connection.targetUser);
              }
            });
            _saving = false;
          });
        } else {
          setState(() {
            _saving = false;
          });
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
            title: Localization.of(context).getString("error"),
            description: result.errors[0].message,
            buttonText: Localization.of(context).getString("ok"),
          ),
        );
      }
    });
  }

  bool hasSearchedTag(User user) {
    bool hasTag = false;
    user.tags.forEach((tag) {
      if (tag.tag.id == widget.card.searchFor.id) {
        hasTag = true;
      }
    });
    return hasTag;
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _saving,
      child: Scaffold(appBar: _buildAppBar(), body: _buildContent()),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: Text(
        '#' + widget.card.searchFor.name,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
      ),
      leading: buildBackButton(Icons.arrow_back, () {
        Navigator.pop(context);
      }),
    );
  }

  Widget _buildContent() {
    return usersWithSearchedTag.isNotEmpty
        ? SingleChildScrollView(child: _buildUsersWithTagCard())
        : (_saving
            ? Container()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    Localization.of(context).getString('noUsersWith') +
                        widget.card.searchFor.name,
                    textAlign: TextAlign.center,
                  ),
                ),
              ));
  }

  Container _buildUsersWithTagCard() {
    return Container(
      margin: const EdgeInsets.only(right: 12.0, left: 12.0, top: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                Localization.of(context).getString('usersWithTag') +
                    '#' +
                    widget.card.searchFor.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              usersWithSearchedTag.isNotEmpty
                  ? _buildUsersList(usersWithSearchedTag)
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersList(List<User> users) {
    return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: users.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedUserIndex = index;
                _saving = true;
              });
              _recommendBloc
                  .createRecommend(widget.card.id, widget.card.postedBy.id,
                      users.elementAt(index).id)
                  .then((result) {
                if (result.errors == null) {
                  Recommend recommend =
                      Recommend.fromJson(result.data['create_recommand']);
                  _shareContact(context, recommend);
                } else {
                  setState(() {
                    _saving = false;
                  });
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => CustomDialog(
                      title: Localization.of(context).getString('error'),
                      description: result.errors[0].message,
                      buttonText: Localization.of(context).getString('ok'),
                    ),
                  );
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.only(top: 12.0, left: 4.0, right: 4.0),
              decoration: BoxDecoration(
                  color: selectedUserIndex != index
                      ? ColorUtils.white
                      : ColorUtils.messageGray,
                  borderRadius: BorderRadius.all(Radius.circular(6.0))),
              child: _buildUserItem(users, index),
            ),
          );
        });
  }

  void _shareContact(BuildContext context, Recommend recommend) async {
    _recommendBloc
        .createConversation(recommend.userAsk)
        .then((pubNubConversation) {
      var pnGCM = PnGCM(WrappedMessage(
          PushNotification(recommend.userSend.name,
              Localization.of(context).getString('sharedContact')),
          UserMessage.withSharedContact(DateTime.now(), recommend.userSend.id,
              recommend.userRecommend, pubNubConversation.id)));
      _recommendBloc
          .sendMessage(pubNubConversation.id, pnGCM)
          .then((messageSent) {
        if (messageSent) {
          setState(() {
            _saving = false;
          });
          Navigator.of(context).pushReplacement(new MaterialPageRoute(
              builder: (BuildContext context) => ChatScreen(
                  pubNubConversation: pubNubConversation)));
        } else {
          print('Could not send message');
        }
      });
    });
  }

  Widget _buildUserItem(List<User> users, int index) {
    int score = getScoreForSearchedTag(
        users.elementAt(index).tags, widget.card.searchFor);
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
              width: 24,
              height: 24,
              child: CircleAvatar(
                child: users.elementAt(index).profilePicUrl == null ||
                        (users.elementAt(index).profilePicUrl != null &&
                            users.elementAt(index).profilePicUrl.isEmpty)
                    ? Text(
                        users.elementAt(index).name.startsWith('+')
                            ? '+'
                            : getInitials(users.elementAt(index).name),
                        style: TextStyle(color: ColorUtils.darkerGray))
                    : null,
                backgroundImage: users.elementAt(index).profilePicUrl != null
                    ? NetworkImage(users.elementAt(index).profilePicUrl)
                    : null,
                backgroundColor: ColorUtils.lightLightGray,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 12.0),
                child: Text(
                  users.elementAt(index).name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            score != -1
                ? Row(
                    children: <Widget>[
                      Icon(
                        Icons.star,
                        color: ColorUtils.orangeAccent,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: Text(score.toString()),
                      ),
                    ],
                  )
                : Text(
                    Localization.of(context).getString('noReviews'),
                    style: TextStyle(color: ColorUtils.lightGray),
                  )
          ],
        ),
        index != users.length - 1
            ? Container(
                margin: const EdgeInsets.only(top: 12.0),
                color: ColorUtils.messageGray,
                height: 1.0,
              )
            : Container()
      ],
    );
  }
}
