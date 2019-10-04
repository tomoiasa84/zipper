import 'dart:typed_data';

import 'package:contractor_search/bloc/users_bloc.dart';
import 'package:contractor_search/layouts/user_details_screen.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/model/user_tag.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/search_users_util.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class UsersScreen extends StatefulWidget {
  @override
  UsersScreenState createState() {
    return UsersScreenState();
  }
}

class UsersScreenState extends State<UsersScreen> {
  UsersBloc _contactsBloc;
  List<User> _usersList = [];

  bool _saving = false;

  @override
  void initState() {
    _contactsBloc = UsersBloc();
    setState(() {
      _saving = true;
    });
    _contactsBloc.getCurrentUser().then((result) {
      if (result.data != null) {
        User currentUser = User.fromJson(result.data['get_user']);
        currentUser.connections.forEach((connection) {
          _usersList.add(connection.targetUser);
        });
        if (mounted) {
          setState(() {
            _saving = false;
          });
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Scaffold(appBar: _buildAppBar(), body: _buildUsersListView()),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
        title: Text(
          Localization.of(context).getString('contacts'),
          style: TextStyle(
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: ColorUtils.darkerGray,
            ),
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: UserSearch(_usersList, (user) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserDetailsScreen(user.id)));
                  }));
            },
          )
        ]);
  }

  ListView _buildUsersListView() {
    return ListView.builder(
        itemCount: _usersList?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          User user = _usersList.elementAt(index);
          return Container(
              margin: EdgeInsets.only(
                  top: (index == 0) ? 16.0 : 0.0,
                  bottom: (index == _usersList.length - 1) ? 16.0 : 0.0,
                  left: 16.0,
                  right: 16.0),
              child: _buildListItem(Uint8List(0), user));
        });
  }

  Card _buildListItem(Uint8List image, User user) {
    UserTag mainTag = getMainTag(user);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
        child: ListTile(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserDetailsScreen(user.id)));
          },
          leading: CircleAvatar(
            child: user.profilePicUrl == null
                ? Text(getInitials(user.name),
                    style: TextStyle(color: ColorUtils.darkerGray))
                : null,
            backgroundImage: user.profilePicUrl != null
                ? NetworkImage(user.profilePicUrl)
                : null,
            backgroundColor: ColorUtils.lightLightGray,
          ),
          title: Row(
            children: <Widget>[
              Flexible(
                child: Container(
                    child: Text(
                  user.isActive ? user.name : user.phoneNumber,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: 'Arial', fontWeight: FontWeight.bold),
                )),
              ),
              user.isActive
                  ? Container(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Image.asset(
                        "assets/images/ic_contacts.png",
                        height: 16.0,
                        width: 16.0,
                      ),
                    )
                  : Container()
            ],
          ),
          subtitle: user.isActive
              ? Text(
                  mainTag != null ? '#' + mainTag.tag.name : '',
                  style: TextStyle(color: ColorUtils.messageOrange),
                )
              : null,
        ),
      ),
    );
  }
}
