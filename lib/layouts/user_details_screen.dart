import 'package:contractor_search/bloc/user_details_bloc.dart';
import 'package:contractor_search/layouts/leave_review_dialog.dart';
import 'package:contractor_search/layouts/reviews_screen.dart';
import 'package:contractor_search/layouts/send_in_chat_screen.dart';
import 'package:contractor_search/model/connection_model.dart';
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
import 'package:permission_handler/permission_handler.dart';

import 'chat_screen.dart';

class UserDetailsScreen extends StatefulWidget {
  final User user;
  final User currentUser;
  final List<User> connections;

  const UserDetailsScreen(
      {Key key, this.user, this.currentUser, this.connections})
      : super(key: key);

  @override
  UserDetailsScreenState createState() => UserDetailsScreenState();
}

class UserDetailsScreenState extends State<UserDetailsScreen> {
  UserDetailsBloc _userDetailsBloc = UserDetailsBloc();
  User _user;
  User _currentUser;
  Connection _connection;
  bool _saving = false;
  bool _connectedToUser = false;
  UserTag _mainUserTag;

  @override
  void initState() {
    _currentUser = widget.currentUser;
    _user = widget.user;
    if (widget.connections.firstWhere((user) => user.id == widget.user.id) !=
        null) {
      _connectedToUser = true;
    }
    _getUserAndCurrentUser();
    super.initState();
  }

  @override
  void dispose() {
    _userDetailsBloc.dispose();
    super.dispose();
  }

  Future _getUserAndCurrentUser() async {
    _userDetailsBloc = UserDetailsBloc();
    if (mounted) {
      setState(() {
        _saving = true;
      });
    }
    _userDetailsBloc.getUserByIdWithMainInfo(widget.user.id);
    _userDetailsBloc.getUserByIdWithMainInfoObservable.listen((result) {
      if (result.errors == null) {
        setState(() {
          _user = User.fromJson(result.data['get_user']);
        });
      }
      getCurrentUserId().then((currentUserId) {
        _userDetailsBloc.getUserByIdWithConnections(currentUserId);
        _userDetailsBloc.getUserByIdWithConnectionsObservable
            .listen((currentUserResult) {
          if (currentUserResult.errors == null) {
            setState(() {
              _currentUser = User.fromJson(currentUserResult.data['get_user']);
              _getMainTag();
              _saving = false;
            });
          } else {
            setState(() {
              _saving = false;
            });
          }
        });
      });
    });
  }

  void _getMainTag() {
    if (_user.tags != null) {
      _mainUserTag = getMainTag(_user);
    }
  }

  _onContactTapped() {
    if (mounted) {
      setState(() {
        _saving = true;
      });
    }
    if (_connectedToUser) {
      _deleteConnection();
    } else {
      _createConnection();
    }
    _getUserAndCurrentUser();
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.disabled) {
      Map<PermissionGroup, PermissionStatus> permissionStatus =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.contacts]);
      return permissionStatus[PermissionGroup.contacts] ??
          PermissionStatus.unknown;
    } else {
      return permission;
    }
  }

  void _createConnection() {
    _getContactPermission().then((permission) {
      if (mounted) {
        setState(() {
          _saving = true;
        });
      }
      if (permission == PermissionStatus.granted) {
        _userDetailsBloc.createConnection(_currentUser.id, _user.id);
        _userDetailsBloc.createConnectionObservable.listen((result) {
          if (result.errors == null) {
            if (widget.connections != null) {
              widget.connections.add(
                  Connection.fromJson(result.data['create_connection'])
                      .targetUser);
              widget.connections.sort((a, b) {
                return a.name.compareTo(b.name);
              });
              widget.connections.sort((a, b) {
                return b.isActive.toString().compareTo(a.isActive.toString());
              });
            }
            _addContactToPhoneAgenda();
          } else {
            _showDialog(Localization.of(context).getString('error'),
                Localization.of(context).getString('anErrorHasOccured'));
          }
        });
      } else {
        _userDetailsBloc.createConnection(_currentUser.id, _user.id);
        _userDetailsBloc.createConnectionObservable.listen((result) {
          if (result.errors == null) {
            _reflectConnectionUI();
          } else {
            _showDialog(Localization.of(context).getString('error'),
                Localization.of(context).getString('anErrorHasOccured'));
          }
        });
      }
    });
  }

  Future<void> _addContactToPhoneAgenda() async {
    _userDetailsBloc.addContact(_user.name, _user.phoneNumber);
    _userDetailsBloc.addContactObservable.listen((result) {
      _reflectConnectionUI();
    });
  }

  void _reflectConnectionUI() {
    if (mounted) {
      setState(() {
        _saving = false;
        _connectedToUser = true;
      });
    }
    _showDialog('', Localization.of(context).getString('createdConnection'));
  }

  void _deleteConnection() {
    _userDetailsBloc.deleteConnection(_connection.id);
    _userDetailsBloc.deleteConnectionObservable.listen((onValue) {
      if (onValue.errors == null) {
        if (mounted) {
          setState(() {
            _saving = false;
            _connectedToUser = false;
          });
        }
        if (widget.connections != null) {
          User user = widget.connections
              .firstWhere((item) => item.id == _user.id, orElse: () => null);
          if (user != null) {
            widget.connections.remove(user);
          }
        }
        _showDialog(
            '', Localization.of(context).getString('deletedConnection'));
      } else {
        _showDialog(Localization.of(context).getString('error'),
            Localization.of(context).getString('anErrorHasOccured'));
      }
    });
  }

  void _sendContactToSomeone() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SendInChatScreen(userToBeShared: _user)));
  }

  void _createConversation() {
    if (mounted) {
      setState(() {
        _saving = true;
      });
    }
    _userDetailsBloc.createConversation(_user);
    _userDetailsBloc.createConversationObservable.listen((pubNubConversation) {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
      if (pubNubConversation != null) {
        Navigator.of(context).push(new MaterialPageRoute(
            builder: (BuildContext context) =>
                ChatScreen(pubNubConversation: pubNubConversation)));
      } else {
        _showDialog(Localization.of(context).getString('error'),
            Localization.of(context).getString('anErrorHasOccured'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      progressIndicator: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(ColorUtils.orangeAccent),
      ),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      _buildTagsCard(),
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
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
          child: _user.profilePicUrl == null || _user.profilePicUrl.isEmpty
              ? Text(_user.name.startsWith('+') ? '+' : getInitials(_user.name),
                  style: TextStyle(color: ColorUtils.darkerGray))
              : null,
          backgroundImage:
              _user.profilePicUrl != null && _user.profilePicUrl.isNotEmpty
                  ? NetworkImage(_user.profilePicUrl)
                  : null,
          backgroundColor: ColorUtils.lightLightGray,
        ),
        Flexible(
          child: Padding(
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
                          Flexible(
                            child: Text(
                              '#' + _mainUserTag.tag.name,
                              overflow: TextOverflow.clip,
                              style: TextStyle(color: ColorUtils.orangeAccent),
                            ),
                          ),
                          _mainUserTag.reviews.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
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
                                      fontSize: 14.0,
                                      color: ColorUtils.darkGray),
                                )
                              : Container()
                        ],
                      )
                    : Container()
              ],
            ),
          ),
        )
      ],
    );
  }

  Container _buildDescription() {
    return _user.description != null && _user.description.isNotEmpty
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

  Image _setFollowButtonState() {
    if (_connectedToUser) {
      return Image.asset('assets/images/ic_contact_accent_bg.png');
    } else {
      return Image.asset('assets/images/ic_contact_gray_bg.png');
    }
  }

  Container _buildActionsButtons() {
    return Container(
      alignment: Alignment.bottomRight,
      padding: const EdgeInsets.only(right: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          GestureDetector(
              onTap: _sendContactToSomeone,
              child: Image.asset('assets/images/ic_share_accent_bg.png')),
          GestureDetector(
            onTap: _onContactTapped,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: _setFollowButtonState(),
            ),
          ),
          Visibility(
            visible: _user.isActive,
            child: GestureDetector(
              onTap: () => _createConversation(),
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Image.asset('assets/images/ic_message_accent_bg.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Stack _buildTagsCard() {
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
                          Localization.of(context).getString("tags"),
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
                            Localization.of(context)
                                .getString("viewAllReviews"),
                          ),
                        )
                      ],
                    ),
                    Container(
                      child: Column(
                        children: _user.tags != null
                            ? generateTags(_user.tags, (userTagId) {
                                openLeaveReviewDialog(userTagId);
                              }, (reviews) {
                                goToReviewsScreen(reviews);
                              },
                                Localization.of(context).getString('noReviews'))
                            : [],
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
            Localization.of(context).getString("tapOnTagToLeaveAReview"),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorUtils.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ));
  }

  void openLeaveReviewDialog(int userTagId) async {
    LeaveReviewModel dialogResult = await showDialog(
      context: context,
      builder: (BuildContext context) => LeaveReviewDialog(),
    );

    if (dialogResult != null) {
      if (mounted) {
        setState(() {
          _saving = true;
        });
      }
      String currentUserId = await getCurrentUserId();
      _userDetailsBloc.createReview(
          currentUserId, userTagId, dialogResult.rating, dialogResult.message);
      _userDetailsBloc.createReviewObservable.listen((result) {
        if (result.errors == null) {
          if (mounted) {
            setState(() {
              _getUserAndCurrentUser();
              _saving = false;
            });
          }
          _showDialog(Localization.of(context).getString('success'),
              Localization.of(context).getString('reviewAdded'));
        } else {
          if (mounted) {
            setState(() {
              _saving = false;
            });
          }
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

  void goToReviewsScreen(List<Review> reviews) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ReviewsScreen(
                  reviews: reviews,
                )));
  }
}
