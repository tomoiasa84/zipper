import 'package:contractor_search/bloc/conversations_bloc.dart';
import 'package:contractor_search/models/Conversation.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  ConversationsScreen({Key key}) : super(key: key);

  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  bool _loading = true;
  String _currentUserId;
  List<PubNubConversation> _pubNubConversations = List();
  final ConversationsBloc _conversationsBloc = ConversationsBloc();

  @override
  void initState() {
    super.initState();
    _getCurrentUserId().then((currentUserId) {
      _currentUserId = currentUserId;
    });
    _conversationsBloc.getPubNubConversations().then((conversations) {
      setState(() {
        _pubNubConversations = conversations;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _loading,
      child: Scaffold(
        body: new Column(children: <Widget>[
          AppBar(
            title: Text(
              'Messages',
              style: TextStyle(
                  color: ColorUtils.textBlack,
                  fontSize: 14,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
          ),
          showConversationsUI(),
        ]),
      ),
    );
  }

  Future<String> _getCurrentUserId() async {
    return await SharedPreferencesHelper.getCurrentUserId();
  }

  Widget showConversationsUI() {
    return Expanded(
      child: Container(
        color: ColorUtils.messageGray,
        child: new Container(
          margin: EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: getListView(_pubNubConversations),
        ),
      ),
    );
  }

  Widget getListView(List<PubNubConversation> pubNubConversations) {
    var listView = ListView.builder(
      padding: EdgeInsets.all(0),
      itemBuilder: (context, position) {
        return GestureDetector(
          child: getConversationUI(pubNubConversations[position]),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(
                    pubNubConversation: pubNubConversations[position])),
          ),
        );
      },
      itemCount: pubNubConversations.length,
    );
    return listView;
  }

  Widget getConversationUI(PubNubConversation conversation) {
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(16, 16, 8, 16),
            width: 40,
            height: 40,
            color: Colors.red,
          ),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: Text(
                          getInterlocutorName(conversation.user1,
                              conversation.user2, _currentUserId),
                          style: TextStyle(
                              fontSize: 14,
                              color: ColorUtils.almostBlack,
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text("",
                          style: TextStyle(
                              fontSize: 12, color: ColorUtils.orangeAccent))
                    ],
                  ),
                ),
                Text(
                    conversation.lastMessage.message.message == null
                        ? "Image"
                        : conversation.lastMessage.message.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 12, color: ColorUtils.darkerGray))
              ],
            ),
          )
        ],
      ),
      margin: EdgeInsets.fromLTRB(0, 0, 0, 4),
      decoration: getRoundedWhiteDecoration(),
      height: 73,
    );
  }

  BoxDecoration getRoundedWhiteDecoration() {
    return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)));
  }
}
