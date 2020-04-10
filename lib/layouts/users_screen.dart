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
  final User user;
  final List<User> connections;
  final Function updateConnections;
  final Function updateConnectedUser;

  const UsersScreen(
      {Key key,
      this.user,
      this.connections,
      this.updateConnections,
      this.updateConnectedUser})
      : super(key: key);

  @override
  UsersScreenState createState() {
    return UsersScreenState();
  }
}

class UsersScreenState extends State<UsersScreen> {
  UsersBloc _usersBloc;
  List<User> _usersList = [];
  bool _saving = false;

  @override
  void initState() {
    _usersBloc = UsersBloc();
    _usersList = widget.connections;
    if (_usersList.isEmpty) {
      print('empty connections list!');
      getCurrentUserConnections();
    }
    super.initState();
  }

  @override
  void dispose() {
    _usersBloc.dispose();
    super.dispose();
  }

  void getCurrentUserConnections() {
    if (mounted) {
      setState(() {
        _saving = true;
      });
    }
    _usersBloc.getCurrentUserWithConnections();
    _usersBloc.getUserByIdWithConnectionObservable.listen((result) {
      if (result.errors == null) {
        User currentUser = User.fromJson(result.data['get_user']);
        List<User> users = currentUser.connections
            .map((connection) => connection.targetUser)
            .toList();
        users.sort((a, b) => a.name.compareTo(b.name));
        users.sort(
            (a, b) => b.isActive.toString().compareTo(a.isActive.toString()));
        widget.updateConnections(users);
        users.forEach((user) {
          _usersList.add(user);
        });
        setState(() {
          _usersList = users;
          _saving = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _saving = false;
          });
        }
      }
    });
  }

  void _checkUsersUpdates() {
    _usersBloc.getCurrentUserWithConnections();
    _usersBloc.getUserByIdWithConnectionObservable.listen((result) {
      if (result.errors == null) {
        User newUser = User.fromJson(result.data['get_user']);
        if (widget.updateConnections != null) {
          widget.updateConnections(newUser.connections);
        }
        List<User> targetUsersList = [];
        newUser.connections.forEach((item) {
          targetUsersList.add(item.targetUser);
        });
        if (_usersList.length != targetUsersList.length) {
          _usersList = targetUsersList;
          if (mounted) {
            setState(() {
              _saving = false;
              _usersList.sort((a, b) {
                return a.name.compareTo(b.name);
              });
              _usersList.sort((a, b) {
                return b.isActive.toString().compareTo(a.isActive.toString());
              });
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _saving = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _saving = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: ModalProgressHUD(
          progressIndicator: CircularProgressIndicator(
            valueColor:
                new AlwaysStoppedAnimation<Color>(ColorUtils.orangeAccent),
          ),
          inAsyncCall: _saving,
          child: Scaffold(
            appBar: _buildAppBar(),
            body: _buildUsersListView(),
          ),
        ));
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
                    navigateToUserDetailsScreen(user);
                  }));
            },
          )
        ]);
  }

  navigateToUserDetailsScreen(user) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserDetailsScreen(
                  user: user,
                  currentUser: widget.user,
                  connections: _usersList,
                )));
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
            navigateToUserDetailsScreen(user);
          },
          leading: CircleAvatar(
            child: user.profilePicUrl == null || user.profilePicUrl.isEmpty
                ? Text(user.name.startsWith('+') ? '+' : getInitials(user.name),
                    style: TextStyle(color: ColorUtils.darkerGray))
                : null,
            backgroundImage:
                user.profilePicUrl != null && user.profilePicUrl.isNotEmpty
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
          subtitle: user.isActive && mainTag != null
              ? Text(
                  '#' + mainTag.tag.name,
                  style: TextStyle(color: ColorUtils.messageOrange),
                )
              : null,
        ),
      ),
    );
  }
}
