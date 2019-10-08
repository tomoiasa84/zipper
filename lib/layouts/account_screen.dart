import 'dart:ui';

import 'package:contractor_search/bloc/account_bloc.dart';
import 'package:contractor_search/layouts/profile_settings_screen.dart';
import 'package:contractor_search/layouts/replies_screen.dart';
import 'package:contractor_search/layouts/reviews_screen.dart';
import 'package:contractor_search/layouts/settings_screen.dart';
import 'package:contractor_search/layouts/sign_up_screen.dart';
import 'package:contractor_search/model/card.dart';
import 'package:contractor_search/model/review.dart';
import 'package:contractor_search/model/tag.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/model/user_tag.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/custom_dialog.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class AccountScreen extends StatefulWidget {
  final ValueChanged<bool> onChanged;
  final bool isStartedFromHomeScreen;

  const AccountScreen({Key key, this.onChanged, this.isStartedFromHomeScreen})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AccountScreenState();
  }
}

class AccountScreenState extends State<AccountScreen> {
  AccountBloc _accountBloc;
  User _user;
  UserTag _mainUserTag;
  bool _saving = false;

  static List<PopupMenuEntry<Object>> getMoreOptions(BuildContext context) {
    return [
      PopupMenuItem(
          value: 0,
          child: Container(
              width: 140.0,
              child: Text(
                Localization.of(context).getString('settings'),
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: ColorUtils.darkGray),
              ))),
      PopupMenuDivider(
        height: 1.0,
      ),
      PopupMenuItem(
        value: 1,
        child: Text(Localization.of(context).getString('signOut')),
        textStyle:
            TextStyle(color: ColorUtils.red, fontWeight: FontWeight.bold),
      ),
    ];
  }

  static List<PopupMenuEntry<Object>> getCardOptions(BuildContext context) {
    return [
      PopupMenuItem(
          value: 0,
          child: Container(
              width: 140.0,
              child: Text(
                Localization.of(context).getString('deletePost'),
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: ColorUtils.red),
              ))),
    ];
  }

  void _select(Object item) {
    switch (item as int) {
      case 0:
        {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SettingsScreen()));
          break;
        }
      case 1:
        {
          signOut();
          break;
        }
    }
    widget.onChanged(false);
  }

  void signOut() {
    setState(() {
      _saving = true;
    });
    _accountBloc.clearUserSession().then((_) {
      setState(() {
        _saving = false;
      });
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => SignUpScreen()),
          (Route<dynamic> route) => false);
    });
  }

  void _getCurrentUserInfo() {
    _accountBloc = AccountBloc();
    setState(() {
      _saving = true;
    });
    _accountBloc.getCurrentUser().then((result) {
      if (result.data != null && mounted) {
        setState(() {
          _user = User.fromJson(result.data['get_user']);
          _user.cards = _user.cards.reversed.toList();
          _saving = false;
          _getMainTag();
        });
      }
    });
  }

  void _getMainTag() {
    if (_user.tags != null) {
      _mainUserTag = getMainTag(_user);
    }
  }

  void _deleteCard(CardModel card) {
    setState(() {
      _saving = true;
    });
    _accountBloc.deleteCard(card.id).then((result) {
      if (result.errors == null) {
        setState(() {
          _saving = false;
          _user.cards.remove(card);
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
            title: Localization.of(context).getString("error"),
            description: result.errors[0].message,
            buttonText: Localization.of(context).getString('ok'),
          ),
        );
      }
    });
  }

  @override
  void initState() {
    _getCurrentUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        inAsyncCall: _saving,
        child: Scaffold(
            appBar:
                _buildAppBar(Localization.of(context).getString('settings')),
            body: SafeArea(
              top: true,
              child: _user != null
                  ? Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                        child: Container(
                          margin: const EdgeInsets.only(top: 16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              _buildMainInfoCard(),
                              _user.tags != null && _user.tags.isNotEmpty
                                  ? _buildSkillsCard()
                                  : Container(),
                              _user.cards != null
                                  ? _buildCardsList()
                                  : Container()
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(),
            )));
  }

  AppBar _buildAppBar(String popupInitialValue) {
    return AppBar(
        centerTitle: true,
        title: Text(
          Localization.of(context).getString('myProfile'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        actions: <Widget>[
          widget.isStartedFromHomeScreen
              ? Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: PopupMenuButton<Object>(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    elevation: 13.2,
                    offset: Offset(100, 110),
                    initialValue: CustomPopupMenu(title: popupInitialValue),
                    onCanceled: () {
                      widget.onChanged(false);
                    },
                    onSelected: (_) {
                      _select(_);
                    },
                    itemBuilder: (BuildContext context) {
                      widget.onChanged(true);
                      return getMoreOptions(context);
                    },
                  ),
                )
              : Container(),
        ],
        automaticallyImplyLeading: false,
        leading: widget.isStartedFromHomeScreen
            ? Container()
            : IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: ColorUtils.darkerGray,
                ),
                onPressed: () => Navigator.pop(context, false),
              ));
  }

  Card _buildMainInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 24.0, bottom: 44.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildNameRow(),
            _buildDescription(),
          ],
        ),
      ),
    );
  }

  Container _buildDescription() {
    return _user.description != null
        ? Container(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              _user.description,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 14.0, color: ColorUtils.darkerGray),
            ),
          )
        : Container();
  }

  Widget _buildNameRow() {
    return Row(
      children: <Widget>[
        CircleAvatar(
          child: _user.profilePicUrl == null
              ? Text(getInitials(_user.name),
                  style: TextStyle(color: ColorUtils.darkerGray))
              : null,
          backgroundImage: _user.profilePicUrl != null
              ? NetworkImage(_user.profilePicUrl)
              : null,
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
              _mainUserTag != null
                  ? Row(
                      children: <Widget>[
                        Text(
                          '#' + _mainUserTag.tag.name,
                          style: TextStyle(color: ColorUtils.orangeAccent),
                        ),
                        _mainUserTag.reviews.isNotEmpty
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, top: 4.0),
                                child: Icon(
                                  Icons.star,
                                  color: ColorUtils.orangeAccent,
                                ),
                              )
                            : Container(),
                        _mainUserTag.reviews.isNotEmpty
                            ? Text(
                                _mainUserTag.score.toString(),
                                style: TextStyle(
                                    fontSize: 14.0, color: ColorUtils.darkGray),
                              )
                            : Container()
                      ],
                    )
                  : Container()
            ],
          ),
        ),
        new Spacer(),
        widget.isStartedFromHomeScreen
            ? GestureDetector(
                child: Image.asset('assets/images/ic_edit_accent_bg.png'),
                onTap: () {
                  _goToSettingsScreen();
                },
              )
            : Container()
      ],
    );
  }

  Widget _buildSkillsCard() {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    Localization.of(context).getString("skills"),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                      onTap: () {
                        List<Review> reviews = [];
                        _user.tags.forEach((item) {
                          reviews.addAll(item.reviews);
                        });
                        goToReviewsScreen(reviews);
                      },
                      child: Text(
                          Localization.of(context).getString("viewAllReviews")))
                ],
              ),
              Container(
                child: Column(
                  children: generateSkills(_user.tags, (_) {}, (reviews) {
                    goToReviewsScreen(reviews);
                  }, Localization.of(context).getString('noReviews')),
                ),
              )
            ],
          ),
        ));
  }

  Widget _buildCardsList() {
    return widget.isStartedFromHomeScreen
        ? ListView.builder(
            shrinkWrap: true,
            primary: false,
            itemCount: _user.cards.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  margin: EdgeInsets.only(
                    top: (index == 0) ? 8.0 : 0.0,
                    bottom: (index == _user.cards.length - 1) ? 24.0 : 0.0,
                  ),
                  child: _buildCardItem(_user.cards.elementAt(index)));
            })
        : Container();
  }

  GestureDetector _buildCardItem(CardModel card) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RepliesScreen(
                      card: card,
                    )));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Stack(
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildCardText(card.searchFor),
                  _buildCreatedAtInfo(card)
                ],
              ),
            ),
            Positioned(
              top: 0.0,
              right: 0.0,
              child: PopupMenuButton<Object>(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                elevation: 13.2,
                offset: Offset(0, 110),
                initialValue: CustomPopupMenu(
                    title: Localization.of(context).getString('deletePost')),
                onCanceled: () {
                  widget.onChanged(false);
                },
                onSelected: (_) {
                  widget.onChanged(false);
                  _deleteCard(card);
                },
                icon: Icon(
                  Icons.more_vert,
                  color: ColorUtils.lightGray30Opacity,
                ),
                itemBuilder: (BuildContext context) {
                  widget.onChanged(true);
                  return getCardOptions(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Row _buildCardText(Tag searchFor) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          child: _user.profilePicUrl == null
              ? Text(getInitials(_user.name),
                  style: TextStyle(color: ColorUtils.darkerGray))
              : null,
          backgroundImage: _user.profilePicUrl != null
              ? NetworkImage(_user.profilePicUrl)
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
                        text: _user.name,
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
                "#" + searchFor.name,
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

  Padding _buildCreatedAtInfo(CardModel card) {
    String difference = getTimeDifference(card.createdAt);
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
                  card.recommendsCount,
                  zero: Localization.of(context).getString('noReplies'),
                  one: card.recommendsCount.toString() +
                      Localization.of(context).getString('reply'),
                  two: card.recommendsCount.toString() +
                      Localization.of(context).getString('replies'),
                  few: card.recommendsCount.toString() +
                      Localization.of(context).getString('replies'),
                  many: card.recommendsCount.toString() +
                      Localization.of(context).getString('replies'),
                  other: card.recommendsCount.toString() +
                      Localization.of(context).getString('replies'),
                ),
                style: TextStyle(color: ColorUtils.darkerGray)),
          ),
        ],
      ),
    );
  }

  Future _goToSettingsScreen() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => ProfileSettingsScreen(_user)));
    _getCurrentUserInfo();
  }

  void goToReviewsScreen(List<Review> reviews) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ReviewsScreen(
                  reviews: reviews,
                )));
  }
}

class CustomPopupMenu {
  CustomPopupMenu({this.title});

  String title;
}
