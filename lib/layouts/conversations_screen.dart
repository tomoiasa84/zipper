import 'package:contractor_search/bloc/conversations_bloc.dart';
import 'package:contractor_search/layouts/select_contact_screen.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
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

class _ConversationsScreenState extends State<ConversationsScreen>
    with WidgetsBindingObserver {
  bool _loading = true;
  String _currentUserId;
  List<PubNubConversation> _pubNubConversations = List();
  final ConversationsBloc _conversationsBloc = ConversationsBloc();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getCurrentUserId().then((currentUserId) {
      _currentUserId = currentUserId;
    });
    _getConversations();
  }

  void _getConversations() {
    print('GET CONVERSATIONS');
    _conversationsBloc.getPubNubConversations().then((conversations) {
      setState(() {
        _pubNubConversations = conversations;
        _loading = false;
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _getConversations();
    }
  }

  void _startNewConversation() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SelectContactScreen(shareContactScreen: false)))
        .then((onValue) {
      _getConversations();
    });
  }

  void _goToChatScreen(PubNubConversation pubNubConversation) {
    var convId = pubNubConversation.id;
    print('CONVERSATION ID IS: $convId');
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ChatScreen(pubNubConversation: pubNubConversation)),
    ).then((onValue) {
      _getConversations();
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
          _showConversationsUI(),
        ]),
        floatingActionButton: Container(
          height: 42,
          width: 42,
          child: FittedBox(
            child: FloatingActionButton(
              onPressed: () {
                _startNewConversation();
              },
              child: Image.asset(
                "assets/images/ic_plus_accent_background.png",
              ),
              backgroundColor: ColorUtils.orangeAccent,
            ),
          ),
        ),
      ),
    );
  }

  Future<String> _getCurrentUserId() async {
    return await SharedPreferencesHelper.getCurrentUserId();
  }

  Widget _showConversationsUI() {
    return Expanded(
      child: Container(
        color: ColorUtils.messageGray,
        child: new Container(
          margin: EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: _getListView(_pubNubConversations),
        ),
      ),
    );
  }

  Widget _getListView(List<PubNubConversation> pubNubConversations) {
    var listView = ListView.builder(
      padding: EdgeInsets.all(0),
      itemBuilder: (context, position) {
        return GestureDetector(
          child: _getConversationUI(pubNubConversations[position]),
          onTap: () => _goToChatScreen(pubNubConversations[position]),
        );
      },
      itemCount: pubNubConversations.length,
    );
    return listView;
  }

  Widget _getConversationUI(PubNubConversation conversation) {
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
                Text(_showConversationLastMessage(conversation),
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
      decoration: _getRoundedWhiteDecoration(),
      height: 73,
    );
  }

  String _showConversationLastMessage(PubNubConversation pubNubConversation) {
    if (pubNubConversation.lastMessage.message.imageDownloadUrl != null) {
      return Localization.of(context).getString('image');
    }
    if (pubNubConversation.lastMessage.message.sharedContact != null) {
      return Localization.of(context).getString('sharedContact');
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
