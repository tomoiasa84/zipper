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
  final List<Conversation> _conversations = [
    new Conversation("", "", ""),
    new Conversation("", "", ""),
    new Conversation("", "", "")
  ];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Column(children: <Widget>[
        AppBar(
          title: Text(
            'Messages',
            style: TextStyle(color: ColorUtils.textBlack, fontSize: 14),
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
          child: getConversationUI(),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen()),
          ),
        );
      },
      itemCount: conversations.length,
    );
    return listView;
  }

  Widget getConversationUI() {
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(16, 16, 8, 16),
            width: 40,
            height: 40,
            color: Colors.red,
          ),
          Column(
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
                        "Name Surname",
                        style: TextStyle(
                            fontSize: 14, color: ColorUtils.almostBlack),
                      ),
                    ),
                    Text("#housekeeper",
                        style: TextStyle(
                            fontSize: 12, color: ColorUtils.strongOrange))
                  ],
                ),
              ),
              Text("Here is just a last message you sent",
                  style: TextStyle(fontSize: 12, color: ColorUtils.mediumGray))
            ],
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
