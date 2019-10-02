import 'package:contractor_search/bloc/user_details_bloc.dart';
import 'package:contractor_search/layouts/leave_review_dialog.dart';
import 'package:contractor_search/layouts/reviews_screen.dart';
import 'package:contractor_search/model/leave_review_model.dart';
import 'package:contractor_search/model/review.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/model/user_tag.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/custom_dialog.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class UserDetailsScreen extends StatefulWidget {
  final String userId;

  UserDetailsScreen(this.userId);

  @override
  UserDetailsScreenState createState() => UserDetailsScreenState();
}

class UserDetailsScreenState extends State<UserDetailsScreen> {
  UserDetailsBloc _userDetailsBloc;
  User _user;
  bool _saving = false;
  UserTag _mainUserTag;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() {
    _userDetailsBloc = UserDetailsBloc();
    if (mounted) {
      setState(() {
        _saving = true;
      });
    }
    _userDetailsBloc.getCurrentUser(widget.userId).then((result) {
      if (result.data != null && mounted) {
        setState(() {
          _user = User.fromJson(result.data['get_user']);
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

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _saving,
      child: _user != null
          ? Scaffold(
              appBar: _buildAppBar(context),
              body: SafeArea(
                child: SingleChildScrollView(
                    child: Container(
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
                      _buildSkillsCard(),
                    ],
                  ),
                )),
              ),
            )
          : Container(
              color: ColorUtils.white,
            ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
        centerTitle: true,
        title: Text(
          _user.name != null ? _user.name : _user.phoneNumber,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: ColorUtils.darkerGray,
          ),
          onPressed: () => Navigator.pop(context, false),
        ));
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
                _user.name != null ? _user.name : _user.phoneNumber,
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
              _mainUserTag != null
                  ? Row(
                      children: <Widget>[
                        Text(
                          '#' + _mainUserTag.tag.name,
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
                          getReviewForMainTag(_user, _mainUserTag),
                          style: TextStyle(
                              fontSize: 14.0, color: ColorUtils.darkGray),
                        )
                      ],
                    )
                  : Container()
            ],
          ),
        )
      ],
    );
  }

  Container _buildDescription() {
    return _user.description != null
        ? Container(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              _user.description,
              style: TextStyle(fontSize: 14.0, color: ColorUtils.darkerGray),
            ),
          )
        : Container();
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

  Stack _buildSkillsCard() {
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 24.0, bottom: 54.0),
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
                            goToReviewsScreen();
                          },
                          child: Text(
                            Localization.of(context)
                                .getString("viewAllReviews"),
                          ),
                        )
                      ],
                    ),
                    Container(
                      child: Column(
                        children: generateSkills(_user.reviews,
                            openLeaveReviewDialog, goToReviewsScreen),
                      ),
                    )
                  ],
                ),
              )),
        ),
        Positioned(
            bottom: 0.0,
            right: 0.0,
            left: 0.0,
            child: _buildLeaveReviewButton()),
      ],
    );
  }

  Container _buildLeaveReviewButton() {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: ColorUtils.orangeAccent),
        margin: const EdgeInsets.symmetric(horizontal: 27.0),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Text(
            Localization.of(context).getString("tapOnSkillToLeaveAReview"),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorUtils.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ));
  }

  void openLeaveReviewDialog(Review review) async {
    LeaveReviewModel dialogResult = await showDialog(
      context: context,
      builder: (BuildContext context) => LeaveReviewDialog(),
    );

    if (dialogResult != null) {
      setState(() {
        _saving = true;
      });
      _userDetailsBloc
          .createReview(widget.userId, review.userTag.id, dialogResult.rating,
              dialogResult.message)
          .then((result) {
        setState(() {
          _saving = false;
        });

        if (result.errors == null) {
          getCurrentUser();
          _showDialog(Localization.of(context).getString('success'),
              Localization.of(context).getString('reviewAdded'));
        } else {
          _showDialog(Localization.of(context).getString('error'),
              result.errors[0].message);
        }
      });
    }
  }

  Future _showDialog(String title, String message) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        title: title,
        description: message,
        buttonText: Localization.of(context).getString('ok'),
      ),
    );
  }

  void goToReviewsScreen() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ReviewsScreen(
                  reviews: _user.reviews,
                )));
  }
}
