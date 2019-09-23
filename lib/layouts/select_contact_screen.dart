import 'dart:typed_data';

import 'package:contractor_search/bloc/select_contact_bloc.dart';
import 'package:contractor_search/layouts/chat_screen.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SelectContactScreen extends StatefulWidget {
  final bool shareContactScreen;

  SelectContactScreen({Key key, @required this.shareContactScreen})
      : super(key: key);

  @override
  _SelectContactScreenState createState() => _SelectContactScreenState();
}

class _SelectContactScreenState extends State<SelectContactScreen> {
  bool _loading = true;
  List<User> _usersList = [];
  final SelectContactBloc _selectContactBloc = SelectContactBloc();

  @override
  void initState() {
    _selectContactBloc.getUsers().then((result) {
      if (result.data != null) {
        final List<Map<String, dynamic>> users =
            result.data['get_users'].cast<Map<String, dynamic>>();
        users.forEach((item) {
          var user = User.fromJson(item);
          if (user.isActive) {
            _usersList.add(user);
          }
        });
        setState(() {
          _loading = false;
        });
      }
    });
    super.initState();
  }

  void _onItemTapped(User user) {
    if (widget.shareContactScreen == true) {
      _selectContactToShare(user);
    } else {
      _startConversation(user);
    }
  }

  void _selectContactToShare(User user) {
    Navigator.pop(context, user);
  }

  void _startConversation(User user) {
    _selectContactBloc.createConversation(user).then((pubNubConversation) {
      Navigator.of(context).pushReplacement(new MaterialPageRoute(
          builder: (BuildContext context) =>
              ChatScreen(pubNubConversation: pubNubConversation)));
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
              widget.shareContactScreen == true
                  ? Localization.of(context).getString('shareContact')
                  : Localization.of(context).getString('startNewConversation'),
              style: TextStyle(
                  color: ColorUtils.textBlack,
                  fontSize: 14,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
          ),
          _showContacts(),
        ]),
      ),
    );
  }

  Widget _showContacts() {
    return Expanded(
      child: _buildUsersListView(),
    );
  }

  ListView _buildUsersListView() {
    return ListView.builder(
        itemCount: _usersList?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          User user = _usersList.elementAt(index);
          return _buildListItem(Uint8List(0), user);
        });
  }

  Container _buildListItem(Uint8List image, User user) {
    return Container(
      margin: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
          child: ListTile(
            onTap: () {
              _onItemTapped(user);
            },
            leading: (image != null && image.length > 0)
                ? CircleAvatar(backgroundImage: MemoryImage(image))
                : CircleAvatar(
                    child: Text(getInitials(user.name),
                        style: TextStyle(color: ColorUtils.darkerGray)),
                    backgroundColor: ColorUtils.lightLightGray,
                  ),
            title: Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                      child: Text(
                    user.name ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'Arial', fontWeight: FontWeight.bold),
                  )),
                )
              ],
            ),
            subtitle: Text(
              "#installer",
              style: TextStyle(color: ColorUtils.messageOrange),
            ),
          ),
        ),
      ),
    );
  }
}