import 'dart:async';

import 'package:contractor_search/bloc/chat_bloc.dart';
import 'package:contractor_search/layouts/image_preview_screen.dart';
import 'package:contractor_search/layouts/select_contact_screen.dart';
import 'package:contractor_search/model/card.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/model/user_tag.dart';
import 'package:contractor_search/models/MessageHeader.dart';
import 'package:contractor_search/models/PnGCM.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/models/PushNotification.dart';
import 'package:contractor_search/models/UserMessage.dart';
import 'package:contractor_search/models/WrappedMessage.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/custom_dialog.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'card_details_screen.dart';

class ChatScreen extends StatefulWidget {
  final PubNubConversation pubNubConversation;
  final String conversationId;

  ChatScreen({Key key, this.pubNubConversation, this.conversationId})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _controller = new ScrollController();
  final List<Object> _listOfMessages = new List();
  final ChatBloc _chatBloc = ChatBloc();
  PubNubConversation _pubNubConversation;
  StreamSubscription _subscription;
  User _interlocutorUser;
  User _currentUser;
  bool _loading = true;

  final TextEditingController _textEditingController =
      new TextEditingController();

  void _handleMessageSubmit(String text) {
    if (text.trim().length > 0) {
      _textEditingController.clear();
      getCurrentUserId().then((userId) {
        _chatBloc.sendMessage(
            _pubNubConversation.id,
            PnGCM(WrappedMessage(
                PushNotification(_currentUser.name, escapeJsonCharacters(text)),
                UserMessage(escapeJsonCharacters(text), DateTime.now(), userId,
                    _pubNubConversation.id))));
      });
    }
  }

  Future _uploadImage(ImageSource imageSource) async {
    await ImagePicker.pickImage(source: imageSource).then((image) {
      if (image != null) {
        setState(() {
          _loading = true;
        });
        _chatBloc.uploadPic(image).then((imageDownloadUrl) {
          UserMessage message = UserMessage.withImage(
              DateTime.now(),
              escapeJsonCharacters(imageDownloadUrl),
              _currentUser.id,
              _pubNubConversation.id);
          _chatBloc
              .sendMessage(
                  _pubNubConversation.id,
                  PnGCM(WrappedMessage(
                      PushNotification(_currentUser.name,
                          Localization.of(context).getString('image')),
                      message)))
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

  void _shareContact(BuildContext context) async {
    final sharedContact = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SelectContactScreen(shareContactScreen: true)),
    );
    //Do something with the result
    getCurrentUserId().then((userId) {
      if (sharedContact != null || sharedContact.isNotEmpty) {
        _chatBloc.sendMessage(
            _pubNubConversation.id,
            PnGCM(WrappedMessage(
                PushNotification(_currentUser.name,
                    Localization.of(context).getString('sharedContact')),
                new UserMessage.withSharedContact(DateTime.now(), userId,
                    sharedContact, _pubNubConversation.id))));
      }
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
    _pubNubConversation = widget.pubNubConversation;
    _initScreen();
    _controller.addListener(_scrollListener);
    _loadMore().then((onValue) {
      setState(() {
        _loading = false;
      });
    });
  }

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {
        _loadMore();
      });
    }
  }

  Future _initScreen() async {
    return getCurrentUserId().then((currentUserId) async {
      await _setMessagesListener(currentUserId);
      setState(() async {
        if (_pubNubConversation == null) {
          await _chatBloc
              .getConversation(widget.conversationId)
              .then((pubNubConversation) {
            _pubNubConversation = pubNubConversation;
          });
        }

        if (currentUserId == _pubNubConversation.user1.id) {
          _currentUser = _pubNubConversation.user1;
          _interlocutorUser = _pubNubConversation.user2;
        } else {
          _currentUser = _pubNubConversation.user2;
          _interlocutorUser = _pubNubConversation.user1;
        }

        await getConversationsUsers();
        _chatBloc.subscribeToPushNotifications(_pubNubConversation.id);
      });
    });
  }

  getConversationsUsers() async {
    await _chatBloc.getUserById(_currentUser.id).then((result) {
      if (result.data != null) {
        setState(() {
          _currentUser = User.fromJson(result.data['get_user']);
        });
      }
    });

    await _chatBloc.getUserById(_interlocutorUser.id).then((result) {
      if (result.data != null) {
        setState(() {
          _interlocutorUser = User.fromJson(result.data['get_user']);
        });
      }
    });
  }

  Future<bool> _loadMore() async {
    if (_pubNubConversation == null) {
      return false;
    }
    if (_chatBloc.historyStart != 0) {
      await _chatBloc
          .getHistoryMessages(_pubNubConversation.id)
          .then((historyMessages) {
        setState(() {
          _listOfMessages.addAll(historyMessages.reversed);
          _addHeadersIfNecessary();
        });
      });
      return true;
    }
    return true;
  }

  Future _setMessagesListener(String currentUserId) async {
    _chatBloc.subscribeToChannel(_pubNubConversation.id, currentUserId);
    _subscription = _chatBloc.ctrl.stream.listen((message) {
      setState(() {
        _listOfMessages.insert(0, message);
      });
      if (lastMessageHasDifferentDate()) {
        setState(() {
          _listOfMessages.insert(
              1, MessageHeader((message as UserMessage).timestamp));
        });
      }
    });
  }

  bool lastMessageHasDifferentDate() {
    var firstBeforeLastMessage = _listOfMessages[1] as UserMessage;
    var lastMessage = _listOfMessages[0] as UserMessage;
    if (firstBeforeLastMessage.timestamp.day == lastMessage.timestamp.day &&
        firstBeforeLastMessage.timestamp.month == lastMessage.timestamp.month &&
        firstBeforeLastMessage.timestamp.year == lastMessage.timestamp.year) {
      return false;
    }
    return true;
  }

  void _addHeadersIfNecessary() {
    if (_listOfMessages.length > 0) {
      var lastItem = _listOfMessages[_listOfMessages.length - 1];
      if (lastItem is UserMessage) {
        setState(() {
          _listOfMessages.insert(
              _listOfMessages.length, MessageHeader(lastItem.timestamp));
        });
      }

      for (var i = 0; i < _listOfMessages.length - 1; i++) {
        var currentItem = _listOfMessages[i];
        var nextItem = _listOfMessages[i + 1];
        if (currentItem is UserMessage) {
          if (_datesDontMatch(currentItem, nextItem)) {
            setState(() {
              _listOfMessages.insert(
                  i + 1, MessageHeader(currentItem.timestamp));
            });
          }
        } else if (currentItem is MessageHeader) {
          if (_duplicateHeader(currentItem, i)) {
            setState(() {
              _listOfMessages.remove(currentItem);
            });
          }
        }
      }
    }
  }

  bool _duplicateHeader(MessageHeader currentItem, int i) {
    if (_listOfMessages.elementAt(_listOfMessages.length - 1) != currentItem) {
      var previousItem = _listOfMessages[i - 1] as UserMessage;
      var nextItem = _listOfMessages[i + 1] as UserMessage;
      if (currentItem.timestamp.day == previousItem.timestamp.day &&
          currentItem.timestamp.day == nextItem.timestamp.day &&
          currentItem.timestamp.month == previousItem.timestamp.month &&
          currentItem.timestamp.month == nextItem.timestamp.month &&
          currentItem.timestamp.year == previousItem.timestamp.year &&
          currentItem.timestamp.month == nextItem.timestamp.month) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  bool _datesDontMatch(UserMessage currentItem, Object nextItem) {
    if (nextItem is UserMessage) {
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
    var name = _interlocutorUser == null ? "" : _interlocutorUser.name;
    return ModalProgressHUD(
      inAsyncCall: _loading,
      child: Scaffold(
        body: new Column(children: <Widget>[
          AppBar(
            title: Text(
              'Message to $name',
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
              onPressed: () => Navigator.pop(context),
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
    return ListView.builder(
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
      controller: _controller,
    );
  }

  void _goToImagePreview(Object item) {
    if (item is UserMessage) {
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
    if (item is UserMessage) {
      if (item.sharedContact != null) {
        UserTag mainTag;
        if (item.sharedContact.tags != null) {
          mainTag = getMainTag(item.sharedContact);
        }
        return generateContactUI(
            item.sharedContact,
            item.sharedContact,
            mainTag != null ? mainTag.tag.name : '',
            mainTag != null ? mainTag.score : -1,
            () => _startConversation(item.sharedContact),
            null,
            () {});
      }

      if (item.cardModel != null) {
        return _buildCardDetails(item.cardModel);
      }

      if (_messageAuthorIsCurrentUser(item)) {
        return _currentUserMessage(position, item);
      } else {
        return _otherUserMessage(position, item);
      }
    }
    return _getMessageHeaderUI(item as MessageHeader);
  }

  Widget _currentUserMessage(int position, UserMessage message) {
    if (_listOfMessages.length > 0 && position < _listOfMessages.length - 1) {
      var nextItem = _listOfMessages[position + 1];
      _showHideCurrentUserIcon(nextItem, message);
    }
    if (message.imageDownloadUrl != null) {
      return _currentUserImageMessageLayout(message);
    }
    return _currentUserMessageLayout(message);
  }

  Widget _otherUserMessage(int position, UserMessage message) {
    if (_listOfMessages.length > 0 && position < _listOfMessages.length - 1) {
      var nextItem = _listOfMessages[position + 1];
      _showHideOtherUserIcon(nextItem, message);
    }
    if (message.imageDownloadUrl != null) {
      return _otherUserImageMessageLayout(message);
    }
    return _otherUserMessageLayout(message);
  }

  void _showHideCurrentUserIcon(Object nextItem, UserMessage message) {
    if (nextItem is UserMessage) {
      if (_messageAuthorIsCurrentUser(nextItem)) {
        message.showUserIcon = false;
      } else {
        message.showUserIcon = true;
      }
    }
  }

  void _showHideOtherUserIcon(Object nextItem, UserMessage message) {
    if (nextItem is UserMessage) {
      if (!_messageAuthorIsCurrentUser(nextItem)) {
        message.showUserIcon = false;
      } else {
        message.showUserIcon = true;
      }
    }
  }

  Widget _currentUserMessageLayout(UserMessage message) {
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
            child: CircleAvatar(
              child: _currentUser.profilePicUrl == null
                  ? Text(getInitials(_currentUser.name),
                      style: TextStyle(color: ColorUtils.darkerGray))
                  : null,
              backgroundImage: _currentUser.profilePicUrl != null
                  ? NetworkImage(_currentUser.profilePicUrl)
                  : null,
              backgroundColor: ColorUtils.lightLightGray,
            ),
          ),
        )
      ],
    );
  }

  Widget _currentUserImageMessageLayout(UserMessage message) {
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
            child: CircleAvatar(
              child: _currentUser.profilePicUrl == null
                  ? Text(getInitials(_currentUser.name),
                      style: TextStyle(color: ColorUtils.darkerGray))
                  : null,
              backgroundImage: _currentUser.profilePicUrl != null
                  ? NetworkImage(_currentUser.profilePicUrl)
                  : null,
              backgroundColor: ColorUtils.lightLightGray,
            ),
          ),
        )
      ],
    );
  }

  Widget _otherUserMessageLayout(UserMessage message) {
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
              child: CircleAvatar(
                child: _interlocutorUser.profilePicUrl == null
                    ? Text(getInitials(_interlocutorUser.name),
                        style: TextStyle(color: ColorUtils.darkerGray))
                    : null,
                backgroundImage: _interlocutorUser.profilePicUrl != null
                    ? NetworkImage(_interlocutorUser.profilePicUrl)
                    : null,
                backgroundColor: ColorUtils.lightLightGray,
              ),
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

  Widget _otherUserImageMessageLayout(UserMessage message) {
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
              child: CircleAvatar(
                child: _interlocutorUser.profilePicUrl == null
                    ? Text(getInitials(_interlocutorUser.name),
                        style: TextStyle(color: ColorUtils.darkerGray))
                    : null,
                backgroundImage: _interlocutorUser.profilePicUrl != null
                    ? NetworkImage(_interlocutorUser.profilePicUrl)
                    : null,
                backgroundColor: ColorUtils.lightLightGray,
              ),
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
      child: Text(
          Localization.of(context)
              .getFormattedDateTime(messageHeader.timestamp),
          textAlign: TextAlign.center,
          style: TextStyle(color: ColorUtils.textGray, fontSize: 14)),
    );
  }

  bool _messageAuthorIsCurrentUser(UserMessage message) {
    return message.messageAuthor == _currentUser.id;
  }

  Widget _buildCardDetails(CardModel cardModel) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CardDetailsScreen(
                      cardId: cardModel.id,
                    )));
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
        child: Stack(
          children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildCardText(cardModel),
                    _buildDetailsText(cardModel),
                    _buildCreatedAtInfo(cardModel),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Row _buildCardText(CardModel cardModel) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          child: cardModel.postedBy.profilePicUrl == null
              ? Text(getInitials(cardModel.postedBy.name),
                  style: TextStyle(color: ColorUtils.darkerGray))
              : null,
          backgroundImage: cardModel.postedBy.profilePicUrl != null
              ? NetworkImage(cardModel.postedBy.profilePicUrl)
              : null,
          backgroundColor: ColorUtils.lightLightGray,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: cardModel.postedBy.name,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            Localization.of(context).getString("isLookingFor"),
                        style: TextStyle(color: ColorUtils.darkerGray)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                "#" + cardModel.searchFor.name,
                style: TextStyle(
                    color: ColorUtils.orangeAccent,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        )
      ],
    );
  }

  Padding _buildCreatedAtInfo(CardModel cardModel) {
    String difference = getTimeDifference(cardModel.createdAt);
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: <Widget>[
          Image.asset('assets/images/ic_access_time.png'),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 16.0),
            child: Text(
              difference + ' ago',
              style: TextStyle(color: ColorUtils.darkerGray),
            ),
          ),
          Image.asset('assets/images/ic_replies_gray.png'),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 16.0),
            child: Text(
                Intl.plural(
                  cardModel.recommendsCount,
                  zero: Localization.of(context).getString('noReplies'),
                  one: cardModel.recommendsCount.toString() +
                      Localization.of(context).getString('reply'),
                  two: cardModel.recommendsCount.toString() +
                      Localization.of(context).getString('replies'),
                  few: cardModel.recommendsCount.toString() +
                      Localization.of(context).getString('replies'),
                  many: cardModel.recommendsCount.toString() +
                      Localization.of(context).getString('replies'),
                  other: cardModel.recommendsCount.toString() +
                      Localization.of(context).getString('replies'),
                ),
                style: TextStyle(
                  color: ColorUtils.darkerGray,
                )),
          ),
        ],
      ),
    );
  }

  Padding _buildDetailsText(CardModel cardModel) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: (cardModel.text != null && cardModel.text.isNotEmpty)
          ? Text(
              cardModel.text,
              style: TextStyle(color: ColorUtils.darkerGray, height: 1.5),
            )
          : Container(),
    );
  }
}
