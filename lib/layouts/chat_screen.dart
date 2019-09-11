import 'dart:async';

import 'package:contractor_search/bloc/chat_bloc.dart';
import 'package:contractor_search/models/Message.dart';
import 'package:contractor_search/models/MessageHeader.dart';
import 'package:contractor_search/models/SharedContact.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  StreamSubscription _subscription;
  final ChatBloc _chatBloc = ChatBloc();
  final List<Object> _listOfMessages = new List();
  final ScrollController _listScrollController = new ScrollController();
  final String _channelID = "2";
  final TextEditingController _textEditingController =
      new TextEditingController();

  void _handleMessageSubmit(String text) {
    if (text.trim().length > 0) {
      _textEditingController.clear();
      setState(() {
        _chatBloc.sendMessage(
            _channelID, new Message(text, DateTime.now(), "myUser"));
      });
    }
  }

  @override
  void dispose() {
    _chatBloc.dispose();
    _subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getHistoryMessages();
    _setMessagesListener();
  }

  void _getHistoryMessages() {
    _chatBloc.getHistoryMessages(_channelID).then((historyMessages) {
      setState(() {
        _listOfMessages.addAll(historyMessages.reversed);
      });
    });
  }

  void _setMessagesListener() {
    _chatBloc.subscribeToChannel(_channelID);
    _subscription = _chatBloc.ctrl.stream.listen((message) {
      setState(() {
        _listOfMessages.insert(0, message);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Column(children: <Widget>[
        AppBar(
          title: Text(
            'Message to Name Surname',
            style: TextStyle(
                color: ColorUtils.textBlack,
                fontSize: 14,
                fontFamily: 'Arial',
                fontWeight: FontWeight.bold),
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
          child: getListView(_listOfMessages),
        ),
      ),
    );
  }

  Widget getListView(List<Object> listOfMessages) {
    var listView = ListView.builder(
      reverse: true,
      padding: EdgeInsets.all(0),
      itemBuilder: (context, position) {
        var item = listOfMessages[position];
        if (item is Message) {
          if (_messageAuthorIsCurrentUser(item)) {
            return currentUserMessage(position, item);
          } else {
            return otherUserMessage(position, item);
          }
        }
        if (item is SharedContact) {
          return getSharedContactUI(item);
        }
        return getMessageHeaderUI(item as MessageHeader);
      },
      itemCount: listOfMessages.length,
      controller: _listScrollController,
    );
    return listView;
  }

  Widget currentUserMessage(int position, Message message) {
    if (position > 0) {
      var previousItem = _listOfMessages[position - 1];

      if (previousItem is Message) {
        if (_messageAuthorIsCurrentUser(previousItem)) {
          return currentUserSecondMessage(message);
        } else {
          return currentUserFirstMessage(message);
        }
      }
    }
    return currentUserFirstMessage(message);
  }

  Widget otherUserMessage(int position, Message message) {
    if (position > 0) {
      var previousItem = _listOfMessages[position - 1];

      if (previousItem is Message) {
        if (_messageAuthorIsCurrentUser(previousItem)) {
          return otherUserFirstMessage(message);
        } else {
          return otherUserSecondMessage(message);
        }
      }
    }
    return otherUserFirstMessage(message);
  }

  Widget currentUserFirstMessage(Message message) {
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
                  message.message,
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
          decoration: new BoxDecoration(
              shape: BoxShape.circle,
              image: new DecorationImage(
                  fit: BoxFit.cover,
                  image: new NetworkImage("https://i.imgur.com/BoN9kdC.png"))),
        )
      ],
    );
  }

  Widget currentUserSecondMessage(Message message) {
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
                  message.message,
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

  Widget otherUserFirstMessage(Message message) {
    return new Row(children: <Widget>[
      Container(
        margin: EdgeInsets.fromLTRB(15, 16, 0, 0),
        width: 32,
        height: 32,
        decoration: new BoxDecoration(
            shape: BoxShape.circle,
            image: new DecorationImage(
                fit: BoxFit.cover,
                image: new NetworkImage("https://i.imgur.com/BoN9kdC.png"))),
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
                message.message,
                textWidthBasis: TextWidthBasis.longestLine,
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
            ],
          ),
        ),
      )
    ]);
  }

  Widget otherUserSecondMessage(Message message) {
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
                  message.message,
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
        controller: _textEditingController,
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
          onPressed: () => _handleMessageSubmit(_textEditingController.text)),
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
          onPressed: () => _handleMessageSubmit(_textEditingController.text)),
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
          onPressed: () => _handleMessageSubmit(_textEditingController.text)),
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
          onPressed: () => _handleMessageSubmit(_textEditingController.text)),
    );
  }

  Widget getMessageHeaderUI(MessageHeader messageHeader) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 22, 00, 0),
      child: Text(messageHeader.timestamp.toIso8601String(),
          textAlign: TextAlign.center,
          style: TextStyle(color: ColorUtils.textGray, fontSize: 14)),
    );
  }

  Widget getSharedContactUI(SharedContact sharedContact) {
    return Container(
      height: 72,
      margin: EdgeInsets.fromLTRB(15, 16, 15, 0),
      child: Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(28, 0, 0, 0),
            decoration: getRoundedOrangeDecoration(),
            child: Container(
              height: 80,
              margin: EdgeInsets.fromLTRB(40, 0, 0, 0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(sharedContact.name,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.bold)),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                sharedContact.hashtag,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(45, 0, 0, 0),
                                child: Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              Text("4.8",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    decoration: getRoundWhiteCircle(),
                    child: new IconButton(
                      icon: Image.asset(
                        "assets/images/ic_inbox_orange.png",
                        color: ColorUtils.messageOrange,
                      ),
                    ),
                    margin: EdgeInsets.fromLTRB(0, 0, 16, 0),
                    width: 40,
                    height: 40,
                  )
                ],
              ),
            ),
          ),
          Container(
              margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
              width: 56,
              height: 56,
              decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                      fit: BoxFit.cover,
                      image: new NetworkImage(
                          "https://image.shutterstock.com/image-photo/close-portrait-smiling-handsome-man-260nw-1011569245.jpg")))),
        ],
      ),
    );
  }

  bool _messageAuthorIsCurrentUser(Message message) {
    return message.from == "myUser";
  }

  BoxDecoration getRoundedWhiteDecoration() {
    return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)));
  }

  BoxDecoration getRoundWhiteCircle() {
    return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)));
  }

  BoxDecoration getRoundedOrangeDecoration() {
    return BoxDecoration(
        color: ColorUtils.messageOrange,
        borderRadius: BorderRadius.all(Radius.circular(8)));
  }
}
