import 'package:contractor_search/bloc/send_in_chat_bloc.dart';
import 'package:contractor_search/model/card.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PnGCM.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/models/PushNotification.dart';
import 'package:contractor_search/models/UserMessage.dart';
import 'package:contractor_search/models/WrappedMessage.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'chat_screen.dart';

class SendInChatScreen extends StatefulWidget {
  final CardModel cardModel;

  SendInChatScreen({Key key, this.cardModel}) : super(key: key);

  @override
  SendInChatScreenState createState() => SendInChatScreenState();
}

class SendInChatScreenState extends State<SendInChatScreen> {
  SendInChatBloc _sendInChatBloc = SendInChatBloc();
  List<User> _usersList = [];
  List<User> _recentUserConversations = List();
  bool _saving = true;
  bool _allUsersLoaded = false;
  bool _recentUsersLoaded = false;
  String _currentUserId;

  @override
  void initState() {
    _getRecentUsers();
    _getAllUsers();
    super.initState();
  }

  void _getRecentUsers() async {
    _recentUserConversations = await _sendInChatBloc.getRecentUsers();
    _recentUsersLoaded = true;
    _hideLoading();
  }

  void _getAllUsers() async {
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
        _allUsersLoaded = true;
        _hideLoading();
      }
    });
  }

  void _hideLoading() {
    if (_allUsersLoaded && _recentUsersLoaded && mounted) {
      setState(() {
        _saving = false;
      });
    }
  }

  void _sendCardToUser(User user) {
    _sendInChatBloc.createConversation(user).then((pubNubConversation) {
      var pnGCM = PnGCM(WrappedMessage(
          PushNotification(
              "Test", _createSharedCardPushNotificationText(widget.cardModel)),
          UserMessage.withSharedCard(DateTime.now(), _currentUserId,
              widget.cardModel, pubNubConversation.id)));

      _sendInChatBloc
          .sendMessage(pubNubConversation.id, pnGCM)
          .then((messageSent) {
        if (messageSent) {
          Navigator.of(context).pushReplacement(new MaterialPageRoute(
              builder: (BuildContext context) =>
                  ChatScreen(pubNubConversation: pubNubConversation)));
        } else {
          print('Could not send message');
        }
      });
    });
  }

  String _createSharedCardPushNotificationText(CardModel cardModel) {
    return widget.cardModel.postedBy.name +
        " " +
        Localization.of(context).getString('isLookingFor') +
        " " +
        widget.cardModel.searchFor.name;
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
          _buildAllFriends(),
        ],
      ),
    );
  }

  Container _buildSearchTextField() {
    return Container(
      padding: const EdgeInsets.only(top: 4.0),
      decoration: new BoxDecoration(
          borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
          border: Border.all(color: ColorUtils.lightLightGray),
          color: Colors.white),
      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: TypeAheadFormField(
        getImmediateSuggestions: true,
        textFieldConfiguration: TextFieldConfiguration(
          decoration: InputDecoration(
            prefix: Text('    '),
            border: InputBorder.none,
            hintStyle: TextStyle(color: ColorUtils.textGray),
            hintText: Localization.of(context).getString('searchs'),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.search,
                color: ColorUtils.darkerGray,
              ),
              onPressed: () {},
            ),
          ),
        ),
        suggestionsCallback: (pattern) {
          List<String> list = [];
          _usersList
              .where((it) =>
                  it.name.toLowerCase().startsWith(pattern.toLowerCase()))
              .toList()
              .forEach((tag) => list.add(tag.name));
          return list;
        },
        itemBuilder: (context, suggestion) {
          int index = _usersList.indexWhere((item) => item.name == suggestion);
          return ListTile(
            title: _buildUserItem(index, _usersList),
          );
        },
        transitionBuilder: (context, suggestionsBox, controller) {
          return suggestionsBox;
        },
        onSuggestionSelected: (suggestion) {
          int index = _usersList.indexWhere((item) => item.name == suggestion);
          _sendCardToUser(_usersList.elementAt(index));
        },
      ),
    );
  }

  Container _buildRecentConversations() {
    return _usersList.isNotEmpty
        ? Container(
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
                    _buildConversationsList(),
                  ],
                ),
              ),
            ),
          )
        : Container();
  }

  Widget _buildConversationsList() {
    return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: _recentUserConversations.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: const EdgeInsets.only(top: 12.0),
            child: _buildUserItem(index, _recentUserConversations),
          );
        });
  }

  Widget _buildUserItem(int index, List<User> usersList) {
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
                  usersList.elementAt(index).name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _sendCardToUser(usersList.elementAt(index)),
              child: Text(
                Localization.of(context).getString('send'),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ColorUtils.orangeAccent),
              ),
            )
          ],
        ),
        index != usersList.length - 1
            ? Container(
                margin: const EdgeInsets.only(top: 12.0),
                color: ColorUtils.messageGray,
                height: 1.0,
              )
            : Container()
      ],
    );
  }

  Container _buildAllFriends() {
    return _usersList.isNotEmpty
        ? Container(
            margin:
                const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0),
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
          )
        : Container();
  }

  Widget _buildAllFriendsList() {
    return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: _usersList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: const EdgeInsets.only(top: 12.0),
            child: _buildUserItem(index, _usersList),
          );
        });
  }
}
