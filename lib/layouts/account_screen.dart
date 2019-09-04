import 'dart:ui';

import 'package:contractor_search/bloc/account_bloc.dart';
import 'package:contractor_search/layouts/phone_auth_screen.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/string_utils.dart';
import 'package:contractor_search/utils/helper.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class AccountScreen extends StatefulWidget {
  final ValueChanged<bool> onChanged;

  const AccountScreen({Key key, this.onChanged}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AccountScreenState();
  }
}

class AccountScreenState extends State<AccountScreen> {
  AccountBloc _accountBloc;

  User _user;
  bool _saving = false;
  var list = List<PopupMenuEntry<Object>>();

  static List<CustomPopupMenu> choices = <CustomPopupMenu>[
    CustomPopupMenu(title: Strings.settings),
    CustomPopupMenu(title: Strings.signOut),
  ];

  static List<PopupMenuEntry<Object>> options = [
    PopupMenuItem(
        value: 0,
        child: Container(
            width: 140.0,
            child: Text(
              choices[0].title,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: ColorUtils.darkGray),
            ))),
    PopupMenuDivider(
      height: 1.0,
    ),
    PopupMenuItem(
      value: 1,
      child: Text(choices[1].title),
      textStyle: TextStyle(color: ColorUtils.red, fontWeight: FontWeight.bold),
    ),
  ];

  void _select(Object item) {
    widget.onChanged(false);
    switch (item as int) {
      case 0:
        {
          break;
        }
      case 1:
        {
          signOut();
          break;
        }
    }
  }

  @override
  void initState() {
    _accountBloc = AccountBloc();
    getCurrentUserId().then((userId) {
      setState(() {
        _saving = true;
      });
      _accountBloc.getCurrentUser(userId).then((result) {
        if (result.data != null) {
          setState(() {
            _user = User.fromJson(result.data['get_user']);
            _saving = false;
          });
        }
      });
    });
    super.initState();
  }

  Future<String> getCurrentUserId() async {
    return await SharedPreferencesHelper.getAccessToken();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        inAsyncCall: _saving,
        child: Scaffold(
            appBar: _buildAppBar(context),
            body: SafeArea(
              top: true,
              child: _user != null
                  ? Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        left: 16.0,
                                        right: 16.0,
                                        top: 24.0,
                                        bottom: 44.0),
                                    child: Column(
                                      children: <Widget>[
                                        _buildNameRow(),
                                        _buildDescription(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                  bottom: 0.0,
                                  right: 0.0,
                                  child: _buildActionsButtons()),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Container(),
            )));
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        Strings.myProfile,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
      ),
      actions: <Widget>[
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          child: PopupMenuButton<Object>(
            elevation: 13.2,
            offset: Offset(100, 110),
            initialValue: choices[1],
            onCanceled: () {
              widget.onChanged(false);
            },
            onSelected: (_) {
              _select(_);
            },
            itemBuilder: (BuildContext context) {
              widget.onChanged(true);
              return options;
            },
          ),
        ),
      ],
      automaticallyImplyLeading: false,
    );
  }

  Container _buildDescription() {
    return Container(
      padding: const EdgeInsets.only(top: 16.0),
      child: Text(
        Strings.termsAndConditionsText,
        style: TextStyle(fontSize: 14.0, color: ColorUtils.darkerGray),
      ),
    );
  }

  Widget _buildNameRow() {
    return Row(
      children: <Widget>[
        CircleAvatar(
          child: Text(getInitials(_user.name),
              style: TextStyle(color: ColorUtils.darkerGray)),
          backgroundColor: ColorUtils.lightLightGray,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _user.name,
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
              Row(
                children: <Widget>[
                  Text(
                    "#housekeeper",
                    style: TextStyle(color: ColorUtils.orangeAccent),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                    child: Icon(
                      Icons.star,
                      color: ColorUtils.orangeAccent,
                    ),
                  ),
                  Text(
                    '4.8',
                    style:
                        TextStyle(fontSize: 14.0, color: ColorUtils.darkGray),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Container _buildActionsButtons() {
    return Container(
      alignment: Alignment.bottomRight,
      padding: const EdgeInsets.only(right: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Image.asset('assets/images/ic_share_accent_bg.png'),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Image.asset('assets/images/ic_contact_accent_bg.png'),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Image.asset('assets/images/ic_message_accent_bg.png'),
          ),
        ],
      ),
    );
  }

  void signOut() {
    setState(() {
      _saving = true;
    });
    FirebaseAuth.instance.signOut().then((_) {
      removeSharedPreferences().then((_) {
        setState(() {
          _saving = true;
        });
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => PhoneAuthScreen()),
            (Route<dynamic> route) => false);
      });
    });
  }

  Future removeSharedPreferences() async {
    await SharedPreferencesHelper.clear();
  }
}

class CustomPopupMenu {
  CustomPopupMenu({this.title});

  String title;
}
