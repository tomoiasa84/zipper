import 'package:contractor_search/bloc/send_in_chat_bloc.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SendInChatScreen extends StatefulWidget {
  @override
  SendInChatScreenState createState() {
    return SendInChatScreenState();
  }
}

class SendInChatScreenState extends State<SendInChatScreen> {
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
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _usersList.isNotEmpty ? _buildContent() : Container(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
        title: Text(
          Localization.of(context).getString('sendInChat'),
          style: TextStyle(fontFamily: 'Arial', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: ColorUtils.darkerGray,
          ),
          onPressed: () => Navigator.pop(context, false),
        ));
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _buildSearchTextField(),
          _buildRecentConversations(),
          _buildAllFriends()
        ],
      ),
    );
  }

  Container _buildSearchTextField() {
    return Container(
      padding: const EdgeInsets.only(left: 20.0, top: 4.0),
      decoration: new BoxDecoration(
          borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
          border: Border.all(color: ColorUtils.lightLightGray),
          color: Colors.white),
      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: TextFormField(
          style: TextStyle(
            color: ColorUtils.textBlack,
          ),
          decoration: InputDecoration(
              border: InputBorder.none,
              hintStyle: TextStyle(color: ColorUtils.textGray),
              hintText: Localization.of(context).getString('searchs'),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.search,
                  color: ColorUtils.darkerGray,
                ),
                onPressed: () {},
              ))),
    );
  }

  Container _buildRecentConversations() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
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
                Localization.of(context).getString('recentConversations'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _usersList.isNotEmpty ? _buildConversationsList() : Container()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversationsList() {
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
            Text(
              Localization.of(context).getString('send'),
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: ColorUtils.orangeAccent),
            )
          ],
        ),
        index != _usersList.length - 1
            ? Container(
                margin: const EdgeInsets.only(top: 12.0),
                color: ColorUtils.lightLightGray,
                height: 1.0,
              )
            : Container()
      ],
    );
  }

  Container _buildAllFriends() {
    return Container(
      margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0),
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
                Localization.of(context).getString('allFriends'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildAllFriendsList()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllFriendsList() {
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
}
