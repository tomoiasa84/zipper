import 'package:contractor_search/bloc/recommend_friend_bloc.dart';
import 'package:contractor_search/model/tag.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RecommendFriendScreen extends StatefulWidget {
  final Tag searchedTag;

  const RecommendFriendScreen({Key key, this.searchedTag}) : super(key: key);

  @override
  RecommendFriendScreenState createState() => RecommendFriendScreenState();
}

class RecommendFriendScreenState extends State<RecommendFriendScreen> {
  List<User> usersWithSearchedTag = [];
  RecommendFriendBloc _recommendBloc;
  bool _saving = false;

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
    getCurrentUserId().then((currentUserId) {
      _recommendBloc.getUsers().then((result) {
        if (result.data != null) {
          if (mounted) {
            setState(() {
              final List<Map<String, dynamic>> users =
                  result.data['get_users'].cast<Map<String, dynamic>>();
              users.forEach((item) {
                User user = User.fromJson(item);
                if (user.id != currentUserId && hasSearchedTag(user)) {
                  usersWithSearchedTag.add(user);
                }
              });
              _saving = false;
            });
          }
        }
      });
    });
  }

  bool hasSearchedTag(User user) {
    bool hasTag = false;
    user.tags.forEach((tag) {
      if (tag.tag.id == widget.searchedTag.id) {
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
        '#' + widget.searchedTag.name,
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
            : Center(
                child: Text(Localization.of(context).getString('noUsersWith') +
                    widget.searchedTag.name),
              ));
  }

  Container _buildUsersWithTagCard() {
    return Container(
      margin: const EdgeInsets.only(right: 16.0, left: 16.0, top: 16.0),
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
                    widget.searchedTag.name,
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
          return Container(
            padding: const EdgeInsets.only(top: 12.0),
            child: _buildUserItem(users, index),
          );
        });
  }

  Widget _buildUserItem(List<User> users, int index) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
                margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
                width: 24,
                height: 24,
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                        fit: BoxFit.cover,
                        image: new NetworkImage(
                            "https://image.shutterstock.com/image-photo/close-portrait-smiling-handsome-man-260nw-1011569245.jpg")))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 12.0),
                child: Text(
                  users.elementAt(index).name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Icon(
              Icons.star,
              color: ColorUtils.orangeAccent,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Text('4.8'),
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
