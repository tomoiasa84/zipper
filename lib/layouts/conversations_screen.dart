import 'package:contractor_search/bloc/conversations_bloc.dart';
import 'package:contractor_search/layouts/card_details_screen.dart';
import 'package:contractor_search/layouts/select_contact_screen.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  final List<PubNubConversation> pubNubConversations;
  final Function updateConversationsList;
  final String currentUserId;

  const ConversationsScreen(
      {Key key,
      this.pubNubConversations,
      this.updateConversationsList,
      this.currentUserId})
      : super(key: key);

  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen>
    with WidgetsBindingObserver {
  bool _loading = false;
  String _currentUserId;
  List<PubNubConversation> _pubNubConversations = List();
  final ConversationsBloc _conversationsBloc = ConversationsBloc();
  Stopwatch stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.currentUserId != null) {
      _currentUserId = widget.currentUserId;
      _pubNubConversations = widget.pubNubConversations;
      _getConversations();
    } else {
      getCurrentUserId().then((currentUserId) {
        _currentUserId = currentUserId;
        if (widget.pubNubConversations != null) {
          _pubNubConversations = widget.pubNubConversations;
          _getConversations();
        } else {
          _loading = true;
          _getConversations();
        }
      });
    }
  }

  void _getConversations() {
    stopwatch.start();
    if (mounted) {
      _conversationsBloc.getPubNubConversations().then((conversations) {
        if (conversations != null) {
          if (widget.updateConversationsList != null) {
            widget.updateConversationsList(conversations);
          }
          if (mounted) {
            setState(() {
              _pubNubConversations = conversations;
              _loading = false;
              _setConversationReadState(conversations);
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _loading = false;
            });
          }
        }
      });
    }
  }

  Future _setConversationReadState(
      List<PubNubConversation> conversations) async {
    for (var conversation in _pubNubConversations) {
      if (conversation.lastMessage.message.cardId == null) {
        var lastMessageTimestamp =
            await SharedPreferencesHelper.getLastMessageTimestamp(
                conversation.id);
        if (lastMessageTimestamp !=
            conversation.lastMessage.message.timestamp.toIso8601String()) {
          if (mounted) {
            setState(() {
              conversation.read = false;
            });
          }
        }
      } else {
        var lastRecommendCount =
            await SharedPreferencesHelper.getCardRecommendsCount(
                conversation.lastMessage.message.cardId.toString());
        if (lastRecommendCount == null) {
          if (mounted) {
            setState(() {
              conversation.read = false;
            });
          }
        }
        if (lastRecommendCount ==
            conversation.lastMessage.message.cardRecommendationsCount) {
          if (mounted) {
            setState(() {
              conversation.read = true;
            });
          }
        } else {
          conversation.read = false;
        }
      }
    }
    print('Finished _getConversations in: ${stopwatch.elapsed}');
  }

  void _startNewConversation() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SelectContactScreen(shareContactScreen: false)));
  }

  void _goToChatScreen(PubNubConversation pubNubConversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ChatScreen(pubNubConversation: pubNubConversation)),
    );
  }

  void _goToCardDetailsScreen(PubNubConversation pubNubConversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CardDetailsScreen(
              cardId: pubNubConversation.lastMessage.message.cardId)),
    );
  }

  @override
  void dispose() {
    _conversationsBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key("conversations_screen_key"),
      onVisibilityChanged: (VisibilityInfo info) {
        if (info.visibleFraction == 1.0) {
          _getConversations();
        }
      },
      child: ModalProgressHUD(
        inAsyncCall: _loading,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              Localization.of(context).getString('messages'),
              style: TextStyle(
                  color: ColorUtils.textBlack,
                  fontSize: 14,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
          ),
          body: _showConversationsUI(),
          floatingActionButton: Container(
            height: 42,
            width: 42,
            child: FittedBox(
              child: FloatingActionButton(
                onPressed: () {
                  _startNewConversation();
                },
                child: Icon(
                  Icons.message,
                  color: ColorUtils.white,
                  size: 28,
                ),
                backgroundColor: ColorUtils.orangeAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _showConversationsUI() {
    return Container(
      color: ColorUtils.messageGray,
      child: new Container(
        margin: EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: _getListView(_pubNubConversations),
      ),
    );
  }

  Widget _getListView(List<PubNubConversation> pubNubConversations) {
    var listView = ListView.builder(
      padding: EdgeInsets.all(0),
      itemBuilder: (context, position) {
        return _getConversationUI(pubNubConversations[position]);
      },
      itemCount: pubNubConversations.length,
    );
    return listView;
  }

  Widget _getConversationUI(PubNubConversation conversation) {
    if (conversation.lastMessage.message.backendMessage) {
      return _getRecommendationConversation(conversation);
    } else {
      return _getConversationWithUsersUI(conversation);
    }
  }

  Widget _getRecommendationConversation(PubNubConversation conversation) {
    return GestureDetector(
      onTap: () => _goToCardDetailsScreen(conversation),
      child: Container(
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(16, 16, 8, 16),
              width: 40,
              height: 40,
              child: CircleAvatar(
                child: conversation.read
                    ? Image.asset('assets/images/ic_bell_gray.png')
                    : Image.asset('assets/images/ic_bell_orange_accent.png'),
                backgroundColor: ColorUtils.lightLightGray,
              ),
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
                          child: Text(
                            Localization.of(context).getString('imLookingFor'),
                            style: TextStyle(
                                fontSize: 14,
                                color: ColorUtils.almostBlack,
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Flexible(
                            child: Text(
                                getRecommendedTitle(conversation
                                    .lastMessage.message.conversationTitle),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: ColorUtils.orangeAccent)))
                      ],
                    ),
                  ),
                  Text(conversation.lastMessage.message.conversationPreview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _getLastMessageTextStyle(conversation))
                ],
              ),
            )
          ],
        ),
        margin: EdgeInsets.fromLTRB(0, 0, 0, 4),
        decoration: _getRoundedWhiteDecoration(),
        height: 73,
      ),
    );
  }

  Widget _getConversationWithUsersUI(PubNubConversation conversation) {
    var user = getInterlocutorFromConversation(
        conversation.user1, conversation.user2, _currentUserId);
    return GestureDetector(
      onTap: () => _goToChatScreen(conversation),
      child: Container(
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(16, 16, 8, 16),
              width: 40,
              height: 40,
              child: CircleAvatar(
                child: user.profilePicUrl == null || user.profilePicUrl.isEmpty
                    ? Text(
                        user.name.startsWith('+')
                            ? '+'
                            : getInitials(user.name),
                        style: TextStyle(color: ColorUtils.darkerGray))
                    : null,
                backgroundImage:
                    user.profilePicUrl != null && user.profilePicUrl.isNotEmpty
                        ? NetworkImage(user.profilePicUrl)
                        : null,
                backgroundColor: ColorUtils.lightLightGray,
              ),
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
                            getInterlocutorFromConversation(conversation.user1,
                                    conversation.user2, _currentUserId)
                                .name,
                            style: TextStyle(
                                fontSize: 14,
                                color: ColorUtils.almostBlack,
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Flexible(
                          child: Text(
                              user.tags.length > 0
                                  ? "#" + getMainTag(user).tag.name
                                  : "",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: ColorUtils.orangeAccent)),
                        )
                      ],
                    ),
                  ),
                  Text(_showConversationLastMessage(conversation),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _getLastMessageTextStyle(conversation))
                ],
              ),
            )
          ],
        ),
        margin: EdgeInsets.fromLTRB(0, 0, 0, 4),
        decoration: _getRoundedWhiteDecoration(),
        height: 73,
      ),
    );
  }

  TextStyle _getLastMessageTextStyle(PubNubConversation pubNubConversation) {
    if (pubNubConversation.read) {
      return TextStyle(fontSize: 12, color: ColorUtils.darkerGray);
    } else {
      return TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: ColorUtils.almostBlack);
    }
  }

  String _showConversationLastMessage(PubNubConversation pubNubConversation) {
    if (pubNubConversation.lastMessage.message.imageDownloadUrl != null) {
      return Localization.of(context).getString('image');
    }
    if (pubNubConversation.lastMessage.message.sharedContact != null) {
      return Localization.of(context).getString('sharedContact');
    }
    if (pubNubConversation.lastMessage.message.cardModel != null) {
      return Localization.of(context).getString('sharedPost');
    }
    if (pubNubConversation.lastMessage.message.message != null) {
      return pubNubConversation.lastMessage.message.message;
    } else {
      return "";
    }
  }

  BoxDecoration _getRoundedWhiteDecoration() {
    return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)));
  }
}
