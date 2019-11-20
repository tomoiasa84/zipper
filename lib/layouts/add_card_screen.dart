import 'dart:convert';

import 'package:contractor_search/bloc/add_card_bloc.dart';
import 'package:contractor_search/model/card.dart';
import 'package:contractor_search/model/tag.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/custom_dialog.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class AddCardScreen extends StatefulWidget {
  final User user;
  final Function updateUsersCards;

  const AddCardScreen({Key key, this.user, this.updateUsersCards})
      : super(key: key);

  @override
  AddCardScreenState createState() => AddCardScreenState();
}

class AddCardScreenState extends State<AddCardScreen> {
  AddCardBloc _addCardBloc;
  TextEditingController _addTagsTextEditingController = TextEditingController();
  TextEditingController _addDetailsTextEditingController =
      TextEditingController();
  bool _saving = false;
  User _user;
  Tag tag;
  List<Tag> tagsList = [];

  @override
  void initState() {
    _addCardBloc = AddCardBloc();
    if (widget.user != null) {
      _user = widget.user;
    } else {
      _getCurrentUserInfo();
    }
    getTags();
    super.initState();
  }

  @override
  void dispose() {
    _addCardBloc.dispose();
    super.dispose();
  }

  void getTags() {
    setState(() {
      _saving = true;
    });
    _addCardBloc.getTags();
    _addCardBloc.getTagsFetcherObservable.listen((result) {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
      if (result.errors == null) {
        final List<Map<String, dynamic>> tags =
            result.data['get_tags'].cast<Map<String, dynamic>>();
        tags.forEach((item) {
          tagsList.add(Tag.fromJson(item));
        });
      }
    });
  }

  void _showDialog(String title, String message) {
    setState(() {
      _saving = false;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        title: title,
        description: message,
        buttonText: Localization.of(context).getString('ok'),
      ),
    );
  }

  void _getCurrentUserInfo() {
    setState(() {
      _saving = true;
    });
    getCurrentUserId().then((userId) {
      _addCardBloc.getUserNameIdPhoneNumberProfilePic(userId);
      _addCardBloc.getUserNameIdPhoneNumberProfilePicObservable
          .listen((result) {
        if (result.errors == null) {
          setState(() {
            _user = User.fromJson(result.data['get_user']);
            _saving = false;
          });
        } else {
          setState(() {
            _saving = false;
          });
          _showDialog(Localization.of(context).getString("error"),
              Localization.of(context).getString("anErrorHasOccured"));
        }
      });
    });
  }

  Future<String> getCurrentUserId() async {
    return await SharedPreferencesHelper.getCurrentUserId();
  }

  void _addSelectedTag() {
    if (_addTagsTextEditingController.text.isNotEmpty) {
      var tagFound = tagsList.firstWhere(
          (tag) => tag.name == _addTagsTextEditingController.text.substring(1),
          orElse: () => null);
      if (tagFound != null) {
        setState(() {
          tag = tagFound;
        });
      }
    }
    _addTagsTextEditingController.clear();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      progressIndicator: CircularProgressIndicator(
        valueColor:
        new AlwaysStoppedAnimation<Color>(ColorUtils.orangeAccent),
      ),
      inAsyncCall: _saving,
      child: Scaffold(
          appBar: _buildAppBar(),
          body: (_user != null)
              ? SingleChildScrollView(
                  child: Column(
                    children: <Widget>[_buildPreviewCard(), _buildTagsCard()],
                  ),
                )
              : Container()),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: Text(
        Localization.of(context).getString('addPost'),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      leading: buildBackButton(Icons.clear, () {
        Navigator.pop(context);
      }),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.check,
            color: ColorUtils.darkGray,
          ),
          onPressed: () {
            if (tag != null) {
              createCard();
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) => CustomDialog(
                  title: Localization.of(context).getString("error"),
                  description:
                      Localization.of(context).getString("createPostError"),
                  buttonText: Localization.of(context).getString("ok"),
                ),
              );
            }
          },
        )
      ],
    );
  }

  void createCard() {
    setState(() {
      _saving = true;
    });
    getCurrentUserId().then((currentUserID) {});
    HtmlEscape escape = HtmlEscape();
    var text = escape.convert(_addDetailsTextEditingController.text.replaceAll("\n", "\\n").replaceAll(r"\", r'\\'));
    _addCardBloc.createCard(
        _user.id, tag.id, text);

    _addCardBloc.createCardObservable.listen((result) {
      if (result.errors == null) {
        getCurrentUserId().then((userId) {
          _addCardBloc.getCurrentUserWithCards(userId);
          _addCardBloc.getCurrentUserWithCardsObservable
              .listen((currentUserResult) {
            setState(() {
              _saving = false;
            });
            if (currentUserResult.errors == null) {
              widget.updateUsersCards(
                  User.fromJson(currentUserResult.data['get_user']).cards);
            }
            Navigator.pop(
                context, CardModel.fromJson(result.data['create_card']));
          });
        });
      } else {
        setState(() {
          _saving = false;
        });
        _showDialog(Localization.of(context).getString("error"),
            Localization.of(context).getString("anErrorHasOccured"));
      }
    });
  }

  Container _buildPreviewCard() {
    return Container(
        margin: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  Localization.of(context).getString("preview"),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildNameRow()
              ],
            ),
          ),
        ));
  }

  Container _buildTagsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                Localization.of(context)
                    .getString('selectTagsYouAreLookingFor'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 16.0),
                child: Wrap(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    _buildTagItem(),
                  ],
                ),
              ),
              _buildAddTagsCard(),
              _buildDetailsTextFiled()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagItem() {
    return tag != null
        ? Container(
            margin: const EdgeInsets.only(bottom: 8.0, right: 10.0),
            decoration: BoxDecoration(
                border: Border.all(color: ColorUtils.lightLightGray),
                borderRadius: BorderRadius.all(Radius.circular(6.0))),
            padding: const EdgeInsets.only(
                top: 8.0, bottom: 8.0, left: 16.0, right: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Text(
                    '#' + tag.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      tag = null;
                    });
                  },
                  child: Icon(
                    Icons.close,
                    color: ColorUtils.orangeAccent,
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  Padding _buildNameRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            child: _user.profilePicUrl == null || _user.profilePicUrl.isEmpty
                ? Text(
                    _user.name.startsWith('+') ? '+' : getInitials(_user.name),
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
                  Text.rich(
                    TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                            text: _user.name,
                            style: TextStyle(
                                color: ColorUtils.textBlack,
                                fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: Localization.of(context)
                                .getString("isLookingFor"),
                            style: TextStyle(
                              color: ColorUtils.darkerGray,
                            )),
                      ],
                    ),
                  ),
                  Text(
                    tag != null ? '#' + tag.name : "",
                    style: TextStyle(
                        color: ColorUtils.orangeAccent,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Stack _buildAddTagsCard() {
    return Stack(
      alignment: const Alignment(1.0, 0.0),
      children: <Widget>[
        TypeAheadFormField(
          getImmediateSuggestions: true,
          autoFlipDirection: true,
          textFieldConfiguration: TextFieldConfiguration(
            controller: _addTagsTextEditingController,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  borderSide:
                      BorderSide(color: ColorUtils.lightLightGray, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  borderSide:
                      BorderSide(color: ColorUtils.lightLightGray, width: 1.0),
                ),
                hintText:
                    Localization.of(context).getString('tagsYouAreLookingFor'),
                hintStyle: TextStyle(
                  fontSize: 14.0,
                  color: ColorUtils.darkerGray,
                ),
                suffix: Text('          ')),
          ),
          suggestionsCallback: (pattern) {
            List<String> list = [];
            tagsList
                .where((it) =>
                    it.name.toLowerCase().startsWith(pattern.toLowerCase()))
                .toList()
                .forEach((tag) => list.add(tag.name));
            return list;
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              title: Text('#' + suggestion),
            );
          },
          transitionBuilder: (context, suggestionsBox, controller) {
            return suggestionsBox;
          },
          onSuggestionSelected: (suggestion) {
            this._addTagsTextEditingController.text = '#' + suggestion;
            _addSelectedTag();
          },
          validator: (value) {
            if (value.isEmpty) {
              return Localization.of(context).getString('locationValidation');
            }
            return null;
          },
        )
      ],
    );
  }

  Container _buildDetailsTextFiled() {
    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      child: TextFormField(
          controller: _addDetailsTextEditingController,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
              borderSide:
                  BorderSide(color: ColorUtils.lightLightGray, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
              borderSide:
                  BorderSide(color: ColorUtils.lightLightGray, width: 1.0),
            ),
            hintText: Localization.of(context).getString('addMoreDetails'),
            hintStyle: TextStyle(
              fontSize: 14.0,
              color: ColorUtils.darkerGray,
            ),
          ),
          keyboardType: TextInputType.multiline,
          maxLines: 5 //Number_of_lines(int),
          ),
    );
  }
}
