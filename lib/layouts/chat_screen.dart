import 'dart:async';

import 'package:contractor_search/bloc/chat_bloc.dart';
import 'package:contractor_search/models/Conversation.dart';
import 'package:contractor_search/models/Message.dart';
import 'package:contractor_search/models/MessageHeader.dart';
import 'package:contractor_search/models/SharedContact.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/utils/custom_load_more_delegate.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loadmore/loadmore.dart';

class ChatScreen extends StatefulWidget {
  final PubNubConversation pubNubConversation;

  ChatScreen({Key key, @required this.pubNubConversation}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String _interlocutor;
  String _currentUserId;
  StreamSubscription _subscription;
  final ChatBloc _chatBloc = ChatBloc();
  final List<Object> _listOfMessages = new List();
  final ScrollController _listScrollController = new ScrollController();

  final TextEditingController _textEditingController =
      new TextEditingController();

  void _handleMessageSubmit(String text) {
    if (text.trim().length > 0) {
      _textEditingController.clear();
      _getCurrentUserId().then((userId) {
        _chatBloc.sendMessage(widget.pubNubConversation.id,
            new Message(text, DateTime.now(), userId));
      });
    }
  }

  Future<String> _getCurrentUserId() async {
    return await SharedPreferencesHelper.getCurrentUserId();
  }

  Future _getImage(ImageSource imageSource) async {
    await ImagePicker.pickImage(source: imageSource).then((image) {
      _chatBloc.uploadPic(image).then((imageDownloadUrl) {
        Message message =
            Message.withImage(DateTime.now(), imageDownloadUrl, _currentUserId);
        _chatBloc.sendMessage(widget.pubNubConversation.id, message);
      });
    });
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
    _getCurrentUserId().then((currentUserId) {
      setState(() {
        _currentUserId = currentUserId;
        _interlocutor = getInterlocutorName(widget.pubNubConversation.user1,
            widget.pubNubConversation.user2, _currentUserId);
        _setMessagesListener();
      });
    });
  }

  Future<bool> _loadMore() async {
    if (_chatBloc.historyStart != 0) {
      await _chatBloc
          .getHistoryMessages(widget.pubNubConversation.id)
          .then((historyMessages) {
        setState(() {
          _listOfMessages.addAll(historyMessages.reversed);
        });
      });
      return true;
    }
    return false;
  }

  void _setMessagesListener() {
    _chatBloc.subscribeToChannel(widget.pubNubConversation.id);
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
            'Message to $_interlocutor',
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
        _showMessagesUI(),
        _showUserInputUI()
      ]),
    );
  }

  Widget _showMessagesUI() {
    return Expanded(
      child: Container(
        color: ColorUtils.messageGray,
        child: new Container(
          margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: _getRoundedWhiteDecoration(),
          child: getListView(_listOfMessages),
        ),
      ),
    );
  }

  Widget getListView(List<Object> listOfMessages) {
    var listView = LoadMore(
      delegate: CustomLoadMoreDelegate(context),
      isFinish: _chatBloc.historyStart == 0,
      onLoadMore: _loadMore,
      child: ListView.builder(
        reverse: true,
        padding: EdgeInsets.all(0),
        itemBuilder: (context, position) {
          var item = listOfMessages[position];
          return _selectMessageLayout(item, position);
        },
        itemCount: listOfMessages.length,
        controller: _listScrollController,
      ),
    );
    return listView;
  }

  Widget _selectMessageLayout(Object item, int position) {
    if (item is Message) {
      if (_messageAuthorIsCurrentUser(item)) {
        return _currentUserMessage(position, item);
      } else {
        return _otherUserMessage(position, item);
      }
    }
    if (item is SharedContact) {
      return _getSharedContactUI(item);
    }
    return _getMessageHeaderUI(item as MessageHeader);
  }

  Widget _currentUserMessage(int position, Message message) {
    if (_listOfMessages.length > 0 && position < _listOfMessages.length - 1) {
      var nextItem = _listOfMessages[position + 1];
      _showHideCurrentUserIcon(nextItem, message);
    }
    return _currentUserMessageLayout(message);
  }

  Widget _otherUserMessage(int position, Message message) {
    if (_listOfMessages.length > 0 && position < _listOfMessages.length - 1) {
      var nextItem = _listOfMessages[position + 1];
      _showHideOtherUserIcon(nextItem, message);
    }
    return _otherUserMessageLayout(message);
  }

  void _showHideCurrentUserIcon(Object nextItem, Message message) {
    if (nextItem is Message) {
      if (_messageAuthorIsCurrentUser(nextItem)) {
        message.showUserIcon = false;
      } else {
        message.showUserIcon = true;
      }
    }
  }

  void _showHideOtherUserIcon(Object nextItem, Message message) {
    if (nextItem is Message) {
      if (!_messageAuthorIsCurrentUser(nextItem)) {
        message.showUserIcon = false;
      } else {
        message.showUserIcon = true;
      }
    }
  }

  Widget _currentUserMessageLayout(Message message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Flexible(
          child: Card(
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
                  Visibility(
                    visible: message.imageDownloadUrl == null,
                    child: Text(
                      message.message,
                      textWidthBasis: TextWidthBasis.longestLine,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      softWrap: true,
                    ),
                  ),
                  Visibility(
                    visible: message.imageDownloadUrl != null,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 16, 15, 0),
                      width: 160,
                      height: 80,
                      decoration: new BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: message.imageDownloadUrl == null
                              ? null
                              : DecorationImage(
                                  fit: BoxFit.cover,
                                  image: new NetworkImage(
                                      message.imageDownloadUrl == null
                                          ? null
                                          : message.imageDownloadUrl))),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Visibility(
          maintainState: true,
          maintainAnimation: true,
          maintainSize: true,
          visible: message.showUserIcon,
          child: Container(
            margin: EdgeInsets.fromLTRB(0, 16, 15, 0),
            width: 32,
            height: 32,
            decoration: new BoxDecoration(
                shape: BoxShape.circle,
                image: new DecorationImage(
                    fit: BoxFit.cover,
                    image:
                        new NetworkImage("https://i.imgur.com/BoN9kdC.png"))),
          ),
        )
      ],
    );
  }

  Widget _otherUserMessageLayout(Message message) {
    return new Row(children: <Widget>[
      Visibility(
        maintainState: true,
        maintainAnimation: true,
        maintainSize: true,
        visible: message.showUserIcon,
        child: Container(
          margin: EdgeInsets.fromLTRB(15, 16, 0, 0),
          width: 32,
          height: 32,
          decoration: new BoxDecoration(
              shape: BoxShape.circle,
              image: new DecorationImage(
                  fit: BoxFit.cover,
                  image: new NetworkImage("https://i.imgur.com/BoN9kdC.png"))),
        ),
      ),
      Flexible(
        child: Card(
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
        ),
      )
    ]);
  }

  Widget _showUserInputUI() {
    return Container(
      color: ColorUtils.messageGray,
      child: Container(
        margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
        height: 50,
        decoration: _getRoundedWhiteDecoration(),
        child: Row(
          children: <Widget>[
            _getUserInputTextField(),
            new Row(
              children: <Widget>[
                _getContactsButton(),
                _getImageButton(),
                _getCameraButton(),
                _getSendButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Flexible _getUserInputTextField() {
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

  SizedBox _getContactsButton() {
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

  SizedBox _getImageButton() {
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
          onPressed: () => _getImage(ImageSource.gallery)),
    );
  }

  SizedBox _getCameraButton() {
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
          onPressed: () => _getImage(ImageSource.camera)),
    );
  }

  SizedBox _getSendButton() {
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

  Widget _getMessageHeaderUI(MessageHeader messageHeader) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 22, 00, 0),
      child: Text(messageHeader.timestamp.toIso8601String(),
          textAlign: TextAlign.center,
          style: TextStyle(color: ColorUtils.textGray, fontSize: 14)),
    );
  }

  Widget _getSharedContactUI(SharedContact sharedContact) {
    return Container(
      height: 72,
      margin: EdgeInsets.fromLTRB(15, 16, 15, 0),
      child: Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(28, 0, 0, 0),
            decoration: _getRoundedOrangeDecoration(),
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
                    decoration: _getRoundWhiteCircle(),
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
    return message.from == _currentUserId;
  }

  BoxDecoration _getRoundedWhiteDecoration() {
    return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)));
  }

  BoxDecoration _getRoundWhiteCircle() {
    return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)));
  }

  BoxDecoration _getRoundedOrangeDecoration() {
    return BoxDecoration(
        color: ColorUtils.messageOrange,
        borderRadius: BorderRadius.all(Radius.circular(8)));
  }
}
