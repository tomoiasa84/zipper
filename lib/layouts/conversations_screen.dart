import 'package:contractor_search/bloc/conversations_bloc.dart';
import 'package:contractor_search/models/Conversation.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  ConversationsScreen({Key key}) : super(key: key);

  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  List<Conversation> _conversations = List();
  final ConversationsBloc _conversationsBloc = ConversationsBloc();

  @override
  void initState() {
    super.initState();
    _conversationsBloc.getPubNubConversations().then((conversations) {
      setState(() {
        _conversations = conversations;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
    );
  }

  Widget showConversationsUI() {
    return Expanded(
      child: Container(
        color: ColorUtils.messageGray,
        child: new Container(
          margin: EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: getListView(_conversations),
        ),
      ),
    );
  }

  Widget getListView(List<Conversation> conversations) {
    var listView = ListView.builder(
      padding: EdgeInsets.all(0),
      itemBuilder: (context, position) {
        return GestureDetector(
          child: getConversationUI(conversations[position]),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ChatScreen(channelId: conversations[position].id)),
          ),
        );
      },
      itemCount: conversations.length,
    );
    return listView;
  }

  Widget getConversationUI(Conversation conversation) {
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
                          conversation.name,
                          style: TextStyle(
                              fontSize: 14,
                              color: ColorUtils.almostBlack,
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text("#housekeeper",
                          style: TextStyle(
                              fontSize: 12, color: ColorUtils.orangeAccent))
                    ],
                  ),
                ),
                Text(conversation.lastMessage.message.message,
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
