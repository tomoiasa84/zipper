import 'package:contractor_search/models/Message.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController textEditingController =
      new TextEditingController();

  final List<Message> listOfMessages = [
    new Message("Bah Liviu", DateTime.now(), false),
    new Message("Ce faci?", DateTime.now(), false),
    new Message(":))", DateTime.now(), false)
  ];

  final ScrollController listScrollController = new ScrollController();

  void _handleSubmit(String text) {
    if (text.trim().length > 0) {
      textEditingController.clear();
      setState(() {
        listOfMessages.add(new Message(text, DateTime.now(), true));
        scrollToBottom();
      });
    }
  }

  void scrollToBottom() {
    listScrollController.animateTo(
        listScrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Column(children: <Widget>[
        AppBar(
          title: Text(
            'Message to Name Surname',
            style: TextStyle(color: ColorUtils.textBlack, fontSize: 14),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: ColorUtils.almostBlack,
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.more_vert,
                color: ColorUtils.almostBlack,
              ),
              tooltip: "More actions",
            )
          ],
          backgroundColor: Colors.white,
        ),
        showMessagesUI(),
        showUserInputUI()
      ]),
    );
  }

  Widget showMessagesUI() {
    return Expanded(
      child: Container(
        color: ColorUtils.messageGray,
        child: new Container(
          margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: getRoundedWhiteDecoration(),
          child: getListView(listOfMessages),
        ),
      ),
    );
  }

  Widget getListView(List<Message> listOfMessages) {
    var listView = ListView.builder(
      itemBuilder: (context, position) {
        if (listOfMessages[position].messageAuthorIsCurrentUser) {
          return currentUserMessage(position);
        } else {
          return otherUserMessage(position);
        }
      },
      itemCount: listOfMessages.length,
      controller: listScrollController,
    );
    return listView;
  }

  Widget currentUserMessage(int position) {
    if (position > 0) {
      if (listOfMessages[position - 1].messageAuthorIsCurrentUser) {
        return currentUserSecondMessage(position);
      } else {
        return currentUserFirstMessage(position);
      }
    }
    return currentUserFirstMessage(position);
  }

  Widget otherUserMessage(int position) {
    if (position > 0) {
      if (listOfMessages[position - 1].messageAuthorIsCurrentUser) {
        return otherUserFirstMessage(position);
      } else {
        return otherUserSecondMessage(position);
      }
    }
    return otherUserFirstMessage(position);
  }

  Widget currentUserFirstMessage(int position) {
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        new Card(
          margin: EdgeInsets.fromLTRB(15, 16, 8, 0),
          color: ColorUtils.messageOrange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: new Padding(
            padding: EdgeInsets.all(8),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                new Text(
                  listOfMessages[position].message,
                  textWidthBasis: TextWidthBasis.longestLine,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 16, 15, 0),
          width: 32,
          height: 32,
          color: Colors.red,
        )
      ],
    );
  }

  Widget currentUserSecondMessage(int position) {
    return Row(
      children: <Widget>[
        new Card(
          margin: EdgeInsets.fromLTRB(15, 8, 55, 0),
          color: ColorUtils.messageOrange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: new Padding(
            padding: EdgeInsets.all(8),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                new Text(
                  listOfMessages[position].message,
                  textWidthBasis: TextWidthBasis.longestLine,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        )
      ],
      mainAxisAlignment: MainAxisAlignment.end,
    );
  }

  Widget otherUserFirstMessage(int position) {
    return new Row(children: <Widget>[
      Container(
        margin: EdgeInsets.fromLTRB(15, 16, 0, 0),
        width: 32,
        height: 32,
        color: Colors.red,
      ),
      new Card(
        margin: EdgeInsets.fromLTRB(8, 16, 15, 0),
        color: ColorUtils.messageGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: new Padding(
          padding: EdgeInsets.all(8),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(
                listOfMessages[position].message,
                textWidthBasis: TextWidthBasis.longestLine,
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
            ],
          ),
        ),
      )
    ]);
  }

  Widget otherUserSecondMessage(int position) {
    return Row(
      children: <Widget>[
        new Card(
          margin: EdgeInsets.fromLTRB(55, 8, 15, 0),
          color: ColorUtils.messageGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: new Padding(
            padding: EdgeInsets.all(8),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(
                  listOfMessages[position].message,
                  textWidthBasis: TextWidthBasis.longestLine,
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget showUserInputUI() {
    return Container(
      color: ColorUtils.messageGray,
      child: Container(
        margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
        height: 50,
        decoration: getRoundedWhiteDecoration(),
        child: Row(
          children: <Widget>[
            getUserInputTextField(),
            new Row(
              children: <Widget>[
                getContactsButton(),
                getImageButton(),
                getCameraButton(),
                getSendButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Flexible getUserInputTextField() {
    return new Flexible(
        child: new Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
      child: new TextField(
        textAlignVertical: TextAlignVertical(y: 0),
        maxLines: null,
        expands: true,
        keyboardType: TextInputType.multiline,
        decoration: new InputDecoration.collapsed(
            hintStyle: TextStyle(color: ColorUtils.textGray),
            hintText: "Type a message..."),
        controller: textEditingController,
      ),
    ));
  }

  SizedBox getContactsButton() {
    return new SizedBox(
      height: 50,
      width: 32,
      child: new IconButton(
          padding: EdgeInsets.fromLTRB(0, 0, 4, 0),
          icon: new Icon(
            Icons.people,
            color: ColorUtils.darkGray,
            size: 24,
          ),
          onPressed: () => _handleSubmit(textEditingController.text)),
    );
  }

  SizedBox getImageButton() {
    return new SizedBox(
      height: 50,
      width: 36,
      child: new IconButton(
          padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
          icon: new Icon(
            Icons.image,
            color: ColorUtils.darkGray,
            size: 24,
          ),
          onPressed: () => _handleSubmit(textEditingController.text)),
    );
  }

  SizedBox getCameraButton() {
    return new SizedBox(
      height: 50,
      width: 36.5,
      child: new IconButton(
          padding: EdgeInsets.fromLTRB(4, 0, 8.5, 0),
          icon: new Icon(
            Icons.camera_alt,
            color: ColorUtils.darkGray,
            size: 24,
          ),
          onPressed: () => _handleSubmit(textEditingController.text)),
    );
  }

  SizedBox getSendButton() {
    return new SizedBox(
      height: 50,
      width: 44.5,
      child: new IconButton(
          padding: EdgeInsets.fromLTRB(8.5, 0, 8, 0),
          icon: new Icon(
            Icons.send,
            color: ColorUtils.messageOrange,
            size: 24,
          ),
          onPressed: () => _handleSubmit(textEditingController.text)),
    );
  }

  BoxDecoration getRoundedWhiteDecoration() {
    return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)));
  }
}
