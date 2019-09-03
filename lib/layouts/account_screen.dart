import 'package:contractor_search/bloc/account_bloc.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/string_utils.dart';
import 'package:contractor_search/utils/helper.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class AccountScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AccountScreenState();
  }
}

class AccountScreenState extends State<AccountScreen> {
  AccountBloc _accountBloc;

  User _user;
  bool _saving = false;

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
        IconButton(
          icon: Icon(
            Icons.more_vert,
            color: ColorUtils.darkGray,
          ),
          onPressed: () {},
        )
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
}
