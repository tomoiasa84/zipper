import 'package:contractor_search/bloc/send_in_chat_bloc.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RecommendFriendScreen extends StatefulWidget {
  @override
  RecommendFriendScreenState createState() => RecommendFriendScreenState();
}

class RecommendFriendScreenState extends State<RecommendFriendScreen> {
  SendInChatBloc _sendInChatBloc;
  List<User> _usersList = [];
  bool _saving = false;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() {
    _sendInChatBloc = SendInChatBloc();
    setState(() {
      _saving = true;
    });
    _sendInChatBloc.getUsers().then((result) {
      if (result.data != null) {
        final List<Map<String, dynamic>> users =
            result.data['get_users'].cast<Map<String, dynamic>>();
        users.forEach((item) {
          var user = User.fromJson(item);
          if (user.isActive) {
            _usersList.add(user);
          }
        });
        if (mounted) {
          setState(() {
            _saving = false;
          });
        }
      }
    });
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
        '#nanny',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
      ),
      leading: buildBackButton(Icons.arrow_back, () {
        Navigator.pop(context);
      }),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.check,
            color: ColorUtils.darkGray,
          ),
          onPressed: () {},
        )
      ],
    );
  }

  Widget _buildContent() {
    return _usersList.isNotEmpty
        ? SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildFriendsWithTagCard(),
                _buildOthersCard()
              ],
            ),
          )
        : Container();
  }

  Container _buildFriendsWithTagCard() {
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
                Localization.of(context).getString('yourFriendsWith') +
                    ' #nanny',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _usersList.isNotEmpty ? _buildUsersList() : Container()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: _usersList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: const EdgeInsets.only(top: 12.0),
            child: _buildUserItem(index),
          );
        });
  }

  Widget _buildUserItem(int index) {
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
                  _usersList.elementAt(index).name,
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
        index != _usersList.length - 1
            ? Container(
                margin: const EdgeInsets.only(top: 12.0),
                color: ColorUtils.messageGray,
                height: 1.0,
              )
            : Container()
      ],
    );
  }

  Container _buildOthersCard() {
    return Container(
      margin: const EdgeInsets.only(right: 16.0, left: 16.0, bottom: 16.0),
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
                Localization.of(context).getString('others'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _usersList.isNotEmpty ? _buildUsersList() : Container()
            ],
          ),
        ),
      ),
    );
  }
}
