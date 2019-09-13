import 'dart:typed_data';

import 'package:contractor_search/bloc/users_bloc.dart';
import 'package:contractor_search/layouts/user_details_screen.dart';
import 'package:contractor_search/model/user.dart';
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
    _contactsBloc.getUsers().then((result) {
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
          _saving = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Scaffold(
          appBar: _buildAppBar(),
          body: DefaultTabController(
            length: 3,
            child: Column(
              children: <Widget>[
                _buildTabBar(),
                _buildContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
        title: Text(
          Localization.of(context).getString('contacts'),
          style: TextStyle(fontFamily: 'Arial', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: ColorUtils.darkerGray,
            ),
            onPressed: () {
              showSearch(context: context, delegate: UserSearch(_usersList));
            },
          )
        ]);
  }

  Column _buildTabBar() {
    return Column(
      children: <Widget>[
        new TabBar(
          labelStyle:
              TextStyle(fontFamily: "Arial", fontWeight: FontWeight.bold),
          isScrollable: true,
          labelColor: ColorUtils.messageOrange,
          unselectedLabelColor: ColorUtils.darkerGray,
          indicatorColor: ColorUtils.messageOrange,
          tabs: _buildTabs(),
        ),
        Container(
          margin: const EdgeInsets.only(left: 21.0, right: 21.0, bottom: 12.0),
          // Add top border
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: ColorUtils.lightLightGray,
                width: 0.6,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Expanded _buildContent() {
    return Expanded(
      child: TabBarView(
        children: <Widget>[_buildUsersListView(), Container(), Container()],
      ),
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserDetailsScreen(user)));
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
                ),
                Container(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Image.asset(
                    "assets/images/ic_contacts.png",
                    height: 16.0,
                    width: 16.0,
                  ),
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

  List<Widget> _buildTabs() {
    return <Widget>[
      Tab(
        text: Localization.of(context).getString('all').toUpperCase(),
      ),
      Tab(
        text: Localization.of(context).getString('lastAccessed').toUpperCase(),
      ),
      Tab(
        text: Localization.of(context).getString('favorites').toUpperCase(),
      ),
    ];
  }
}
