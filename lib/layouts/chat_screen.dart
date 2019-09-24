import 'dart:async';
import 'dart:io';

import 'package:contractor_search/bloc/chat_bloc.dart';
import 'package:contractor_search/layouts/image_preview_screen.dart';
import 'package:contractor_search/layouts/select_contact_screen.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/Message.dart';
import 'package:contractor_search/models/MessageHeader.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/custom_dialog.dart';
import 'package:contractor_search/utils/custom_load_more_delegate.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loadmore/loadmore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ChatScreen extends StatefulWidget {
  final PubNubConversation pubNubConversation;

  ChatScreen({Key key, @required this.pubNubConversation}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _loading = false;
  String _interlocutor;
  String _currentUserId;
  StreamSubscription _subscription;
  final ChatBloc _chatBloc = ChatBloc();
  final List<Object> _listOfMessages = new List();
  final ScrollController _listScrollController = new ScrollController();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

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

  Future _uploadImage(ImageSource imageSource) async {
    await ImagePicker.pickImage(source: imageSource).then((image) {
      if (image != null) {
        setState(() {
          _loading = true;
        });
        _chatBloc.uploadPic(image).then((imageDownloadUrl) {
          Message message = Message.withImage(DateTime.now(),
              escapeJsonCharacters(imageDownloadUrl), _currentUserId);
          _chatBloc
              .sendMessage(widget.pubNubConversation.id, message)
              .then((messageSent) {
            if (!messageSent) {
              _showDialog(
                  Localization.of(context).getString('error'),
                  Localization.of(context).getString('somethingWentWrong'),
                  Localization.of(context).getString('ok'));
            }
            setState(() {
              _loading = false;
            });
          });
        });
      }
    });
  }

  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iosPermission();

    _firebaseMessaging.getToken().then((deviceId) {
      print('DEVICE TOKEN IS: $deviceId');
      _chatBloc.subscribeToPushNotifications(
          deviceId, widget.pubNubConversation.id);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  void iosPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  void _shareContact(BuildContext context) async {
    final sharedContact = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SelectContactScreen(shareContactScreen: true)),
    );
    //Do something with the result
    _getCurrentUserId().then((userId) {
      _chatBloc.sendMessage(widget.pubNubConversation.id,
          new Message.withSharedContact(DateTime.now(), userId, sharedContact));
    });
  }

  void _startConversation(User user) {
    _chatBloc.createConversation(user).then((pubNubConversation) {
      Navigator.of(context).pushReplacement(new MaterialPageRoute(
          builder: (BuildContext context) =>
              ChatScreen(pubNubConversation: pubNubConversation)));
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
    firebaseCloudMessagingListeners();
    _getCurrentUserId().then((currentUserId) {
      setState(() {
        _currentUserId = currentUserId;
        _interlocutor = getInterlocutorName(widget.pubNubConversation.user1,
            widget.pubNubConversation.user2, _currentUserId);
        _setMessagesListener(currentUserId);
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
          _addHeadersIfNecessary();
        });
      });
      return true;
    }
    return false;
  }

  void _setMessagesListener(String currentUserId) {
    _chatBloc.subscribeToChannel(widget.pubNubConversation.id, currentUserId);
    _subscription = _chatBloc.ctrl.stream.listen((message) {
      setState(() {
        _listOfMessages.insert(0, message);
        _addHeadersIfNecessary();
      });
    });
  }

  void _addHeadersIfNecessary() {
    if (_listOfMessages.length > 0) {
      var lastItem = _listOfMessages[_listOfMessages.length - 1];
      if (lastItem is Message) {
        setState(() {
          _listOfMessages.insert(
              _listOfMessages.length, MessageHeader(lastItem.timestamp));
        });
      }

      for (var i = 0; i < _listOfMessages.length - 1; i++) {
        var currentItem = _listOfMessages[i];
        var nextItem = _listOfMessages[i + 1];
        if (currentItem is Message) {
          if (_datesDontMatch(currentItem, nextItem)) {
            _listOfMessages.insert(i + 1, MessageHeader(currentItem.timestamp));
          }
        }
      }
    }
  }

  bool _datesDontMatch(Message currentItem, Object nextItem) {
    if (nextItem is Message) {
      return !(currentItem.timestamp.day == nextItem.timestamp.day &&
          currentItem.timestamp.month == nextItem.timestamp.month &&
          currentItem.timestamp.year == nextItem.timestamp.year);
    } else if (nextItem is MessageHeader) {
      return !(currentItem.timestamp.day == nextItem.timestamp.day &&
          currentItem.timestamp.month == nextItem.timestamp.month &&
          currentItem.timestamp.year == nextItem.timestamp.year);
    }
    return false;
  }

  void _showDialog(String title, String message, String buttonText) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        title: title,
        description: message,
        buttonText: buttonText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _loading,
      child: Scaffold(
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
            backgroundColor: Colors.white,
          ),
          _showMessagesUI(),
          _showUserInputUI()
        ]),
      ),
    );
  }

  Widget _showMessagesUI() {
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
    var listView = LoadMore(
      delegate: CustomLoadMoreDelegate(context),
      isFinish: _chatBloc.historyStart == 0,
      onLoadMore: _loadMore,
      child: ListView.builder(
        reverse: true,
        padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
        itemBuilder: (context, position) {
          var item = listOfMessages[position];
          return GestureDetector(
            child: _selectMessageLayout(item, position),
            onTap: () => _goToImagePreview(item),
          );
        },
        itemCount: listOfMessages.length,
        controller: _listScrollController,
      ),
    );
    return listView;
  }

  void _goToImagePreview(Object item) {
    if (item is Message) {
      if (item.imageDownloadUrl != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImagePreviewScreen(
                    imageDownloadUrl: item.imageDownloadUrl)));
      }
    }
  }

  Widget _selectMessageLayout(Object item, int position) {
    if (item is Message) {
      if (item.sharedContact != null) {
        return _getSharedContactUI(item.sharedContact);
      }

      if (_messageAuthorIsCurrentUser(item)) {
        return _currentUserMessage(position, item);
      } else {
        return _otherUserMessage(position, item);
      }
    }
    return _getMessageHeaderUI(item as MessageHeader);
  }

  Widget _currentUserMessage(int position, Message message) {
    if (_listOfMessages.length > 0 && position < _listOfMessages.length - 1) {
      var nextItem = _listOfMessages[position + 1];
      _showHideCurrentUserIcon(nextItem, message);
    }
    if (message.imageDownloadUrl != null) {
      return _currentUserImageMessageLayout(message);
    }
    return _currentUserMessageLayout(message);
  }

  Widget _otherUserMessage(int position, Message message) {
    if (_listOfMessages.length > 0 && position < _listOfMessages.length - 1) {
      var nextItem = _listOfMessages[position + 1];
      _showHideOtherUserIcon(nextItem, message);
    }
    if (message.imageDownloadUrl != null) {
      return _otherUserImageMessageLayout(message);
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
                      message.message != null ? message.message : "",
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

  Widget _currentUserImageMessageLayout(Message message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Flexible(
          child: Card(
            margin: EdgeInsets.fromLTRB(8, 16, 15, 0),
            color: ColorUtils.messageGray,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: new BorderRadius.circular(8.0),
              child: Container(
                width: 120,
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
    return new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
                      image:
                          new NetworkImage("https://i.imgur.com/BoN9kdC.png"))),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
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

  Widget _otherUserImageMessageLayout(Message message) {
    return new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
                      image:
                          new NetworkImage("https://i.imgur.com/BoN9kdC.png"))),
            ),
          ),
          Flexible(
            child: Card(
              margin: EdgeInsets.fromLTRB(8, 16, 15, 0),
              color: ColorUtils.messageGray,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: new BorderRadius.circular(8.0),
                child: Container(
                  width: 120,
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
        decoration: getRoundedWhiteDecoration(),
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
          onPressed: () => _shareContact(context)),
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
          onPressed: () => _uploadImage(ImageSource.gallery)),
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
          onPressed: () => _uploadImage(ImageSource.camera)),
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
      child: Text(getFormattedDateTime(messageHeader.timestamp),
          textAlign: TextAlign.center,
          style: TextStyle(color: ColorUtils.textGray, fontSize: 14)),
    );
  }

  Widget _getSharedContactUI(User user) {
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
                        Text(user.name,
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
                                "#hardcoded tag",
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
                      onPressed: () => _startConversation(user),
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
}
