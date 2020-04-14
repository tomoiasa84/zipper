import 'dart:io';

import 'package:contractor_search/bloc/my_profile_settings_bloc.dart';
import 'package:contractor_search/model/tag.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/model/user_tag.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/custom_dialog.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:graphql/src/core/query_result.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class MyProfileSettingsScreen extends StatefulWidget {
  final User user;

  MyProfileSettingsScreen(this.user);

  @override
  MyProfileSettingsScreenState createState() => MyProfileSettingsScreenState();
}

class MyProfileSettingsScreenState extends State<MyProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameTextEditingController = TextEditingController();
  TextEditingController _mainTextEditingController = TextEditingController();
  TextEditingController _bioTextEditingController = TextEditingController();
  TextEditingController _addTagsTextEditingController = TextEditingController();
  String name;
  List<UserTag> userTagsList = [];
  List<Tag> tagsList = [];
  UserTag userTag;
  bool _saving = false;
  MyProfileSettingsBloc _myProfileSettingsBloc = MyProfileSettingsBloc();
  bool _autoValidate = false;
  File _profilePic;
  Tag tagCreated;

  @override
  void initState() {
    _fetchUsefulData();
    _myProfileSettingsBloc.createUserTagObservable.listen((result) {
      setState(() {
        _saving = false;
      });
      if (result.errors == null && tagCreated != null) {
        _updateTagAdded(tagCreated, result);
      } else {
        _showDialog(
            Localization.of(context).getString("error"),
            Localization.of(context).getString("anErrorHasOccured"),
            Localization.of(context).getString("ok"));
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _myProfileSettingsBloc.dispose();
    super.dispose();
  }

  void getTags() {
    _myProfileSettingsBloc.getTags();
    _myProfileSettingsBloc.getTagsObservable.listen((result) {
      print("getTagsObservable called");
      if (result.errors == null) {
        final List<Map<String, dynamic>> tags =
            result.data['get_tags'].cast<Map<String, dynamic>>();
        tags.forEach((item) {
          var tagItem = Tag.fromJson(item);
          if (userTagsList.isNotEmpty) {
            var tagFound = userTagsList.firstWhere(
                (tag) => tag.tag.id == tagItem.id,
                orElse: () => null);
            if (tagFound == null &&
                (userTag != null && userTag.tag.id != tagItem.id)) {
              tagsList.add(tagItem);
            }
          } else {
            tagsList.add(tagItem);
          }
        });
      }
    });
  }

  void _updateProfile() {
    setState(() {
      _saving = true;
    });
    if (userTag != null &&
        (_mainTextEditingController.text.isNotEmpty &&
            _mainTextEditingController.text.substring(1) != userTag.tag.name)) {
      UserTag newMainUserTag = userTagsList.firstWhere(
          (userTag) =>
              userTag.tag.name == _mainTextEditingController.text.substring(1),
          orElse: () => null);

      if (newMainUserTag != null) {
        _myProfileSettingsBloc.updateMainUserTag(newMainUserTag.id);
        _myProfileSettingsBloc.updateMainUserTagObservable
            .listen((newMainTagResult) {
          if (newMainTagResult.errors == null) {
            updateUser();
          } else {
            _showDialog(
                Localization.of(context).getString("error"),
                Localization.of(context).getString("anErrorHasOccured"),
                Localization.of(context).getString("ok"));
          }
        });
      } else {
        _showDialog(
            Localization.of(context).getString('error'),
            Localization.of(context).getString('select_valid_tag'),
            Localization.of(context).getString('ok'));
      }
    } else {
      updateUser();
    }
  }

  Future<String> _uploadUserProfilePicture() async {
    return await _myProfileSettingsBloc.uploadPic(_profilePic);
  }

  Future updateUser() async {
    var profilePicUrl;

    if (_profilePic != null) {
      await _uploadUserProfilePicture().then((imageUrl) async {
        profilePicUrl = imageUrl;
      });
    } else {
      profilePicUrl =
          widget.user.profilePicUrl != null ? widget.user.profilePicUrl : "";
    }

    _myProfileSettingsBloc.updateUser(
        widget.user.id,
        widget.user.firebaseId,
        _nameTextEditingController.text,
        widget.user.location.id,
        true,
        widget.user.phoneNumber,
        profilePicUrl,
        _bioTextEditingController.text);
    _myProfileSettingsBloc.updateUserObservable.listen((result) {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
      if (result.errors == null) {
        Navigator.pop(context);
      }
    });
  }

  void _selectImage() async {
    await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 15)
        .then((image) {
      if (image != null) {
        setState(() {
          _profilePic = image;
        });
      }
    });
  }

  Future<void> _createNewUserTag() async {
    setState(() {
      _saving = true;
    });
    Tag tag = tagsList.firstWhere(
        (tag) => tag.name == _addTagsTextEditingController.text.substring(1),
        orElse: () => null);
    if (tag != null) {
      _myProfileSettingsBloc.createUserTag(widget.user.id, tag.id);
      tagCreated = tag;
    }
  }

  void _updateTagAdded(Tag tag, QueryResult result) {
    setState(() {
      tagsList.remove(tag);
      UserTag userTagItem = UserTag.fromJson(result.data['create_userTag']);
      userTagsList.add(userTagItem);
      if (userTag == null) {
        userTag = userTagItem;
        setState(() {
          _mainTextEditingController.text = '#' + userTag.tag.name;
        });
      }
    });
  }

  void _deleteUserTag(UserTag item) {
    setState(() {
      _saving = true;
    });
    _myProfileSettingsBloc.deleteUserTag(item.id);
    _myProfileSettingsBloc.deleteUserTagObservable.listen((result) {
      setState(() {
        _saving = false;
      });
      if (result.errors == null) {
        _updateTagDeleted(item);
      } else {
        _showDialog(
            Localization.of(context).getString("error"),
            Localization.of(context).getString("anErrorHasOccured"),
            Localization.of(context).getString("ok"));
      }
    });
  }

  void _updateTagDeleted(UserTag item) {
    setState(() {
      tagsList.add(item.tag);
      userTagsList.remove(item);
      if (userTagsList.isEmpty) {
        userTag = null;
        _mainTextEditingController.clear();
      } else if (userTag != null && !userTagsList.contains(userTag)) {
        _myProfileSettingsBloc.updateMainUserTag(userTagsList[0].id);
        _myProfileSettingsBloc.updateMainUserTagObservable
            .listen((updateNewTagResult) {
          setState(() {
            _mainTextEditingController.text = '#' +
                UserTag.fromJson(updateNewTagResult.data['update_userTag'])
                    .tag
                    .name;
          });
        });
      }
    });
  }

  void _fetchUsefulData() {
    getTags();
    widget.user.tags.forEach((item) {
      if (item.defaultTag) {
        userTag = item;
      }
      userTagsList.add(item);
    });
    _nameTextEditingController.value =
        new TextEditingValue(text: widget.user.name);
    _mainTextEditingController.value = new TextEditingValue(
        text: (userTag != null) ? '#' + userTag.tag.name : "");
    _bioTextEditingController.value = new TextEditingValue(
        text: widget.user.description != null ? widget.user.description : "");
    name = widget.user.name;
  }

  void _addTag() {
    setState(() {
      if (_addTagsTextEditingController.text.isNotEmpty) {
        _createNewUserTag();
      }
    });
    _addTagsTextEditingController.clear();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      progressIndicator: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(ColorUtils.orangeAccent),
      ),
      inAsyncCall: _saving,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Container(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  _buildFirstDataSet(),
                  _buildTagsSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        Localization.of(context).getString('myProfile'),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      leading: buildBackButton(Icons.arrow_back, () {
        Navigator.pop(context);
      }),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.check,
            color: ColorUtils.darkGray,
          ),
          onPressed: () {
            FocusScope.of(context).requestFocus(FocusNode());
            if (_formKey.currentState.validate()) {
              _updateProfile();
            } else {
              setState(() {
                _autoValidate = true;
              });
            }
          },
        )
      ],
    );
  }

  Card _buildFirstDataSet() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Form(
          key: _formKey,
          autovalidate: _autoValidate,
          child: Column(
            children: <Widget>[
              _buildProfilePictureRow(),
              _buildNameRow(),
              _buildMainRow(),
              _buildBioRow(),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider _backgroundImage() {
    if (_profilePic != null) {
      return FileImage(_profilePic);
    } else {
      if (widget.user.profilePicUrl == null ||
          widget.user.profilePicUrl.isEmpty) {
        return null;
      } else {
        return NetworkImage(widget.user.profilePicUrl);
      }
    }
  }

  Row _buildProfilePictureRow() {
    return Row(
      children: <Widget>[
        CircleAvatar(
          child: widget.user.profilePicUrl == null ||
                  widget.user.profilePicUrl.isEmpty
              ? Text(
                  widget.user.name.startsWith('+')
                      ? '+'
                      : getInitials(widget.user.name),
                  style: TextStyle(color: ColorUtils.darkerGray))
              : null,
          backgroundImage: _backgroundImage(),
          backgroundColor: ColorUtils.getColorForName(widget.user.name),
        ),
        GestureDetector(
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              Localization.of(context).getString('changeProfilePhoto'),
              style: TextStyle(color: ColorUtils.orangeAccent),
            ),
          ),
          onTap: () => _selectImage(),
        ),
      ],
    );
  }

  Padding _buildNameRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 26.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Text(
              Localization.of(context).getString('name'),
              style: TextStyle(fontSize: 14.0),
            ),
          ),
          Flexible(
            flex: 3,
            child: TextFormField(
              controller: _nameTextEditingController,
              textAlign: TextAlign.left,
              autovalidate: _autoValidate,
              onChanged: (value) {
                this.name = value;
              },
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: ColorUtils.orangeAccent)),
                enabledBorder: new UnderlineInputBorder(
                    borderSide: BorderSide(color: ColorUtils.lightGray)),
                hintText: Localization.of(context).getString('nameSurname'),
                hintStyle:
                    TextStyle(fontSize: 14.0, color: ColorUtils.darkerGray),
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return Localization.of(context).getString('nameValidation');
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Padding _buildMainRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 26.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Text(
              Localization.of(context).getString('main'),
              style: TextStyle(fontSize: 14.0),
            ),
          ),
          Flexible(
            flex: 3,
            child: TypeAheadFormField(
              getImmediateSuggestions: true,
              textFieldConfiguration: TextFieldConfiguration(
                controller: _mainTextEditingController,
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: ColorUtils.orangeAccent)),
                  enabledBorder: new UnderlineInputBorder(
                      borderSide: BorderSide(color: ColorUtils.lightGray)),
                  hintText: Localization.of(context).getString('addATag'),
                  hintStyle:
                      TextStyle(fontSize: 14.0, color: ColorUtils.darkerGray),
                ),
              ),
              suggestionsCallback: (pattern) {
                if (pattern.startsWith('#')) {
                  pattern = pattern.substring(1);
                }

                List<String> list = [];
                userTagsList
                    .where((it) => it.tag.name
                        .toLowerCase()
                        .startsWith(pattern.toLowerCase()))
                    .toList()
                    .forEach((tag) => list.add(tag.tag.name));
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
                this._mainTextEditingController.text = '#' + suggestion;
              },
            ),
          ),
        ],
      ),
    );
  }

  Padding _buildBioRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 26.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Text(
              Localization.of(context).getString('bio'),
              style: TextStyle(fontSize: 14.0),
            ),
          ),
          Flexible(
            flex: 3,
            child: TextFormField(
              maxLines: null,
              style: TextStyle(color: ColorUtils.darkGray, height: 1.5),
              controller: _bioTextEditingController,
              textAlign: TextAlign.justify,
              autovalidate: _autoValidate,
              onChanged: (value) {
                this.name = value;
              },
              decoration: InputDecoration(
                hintText: Localization.of(context).getString('addDescription'),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _buildTagsSection() {
    return Container(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                Localization.of(context).getString('tags'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 16.0),
                child: Wrap(
                  direction: Axis.horizontal,
                  children: _buildTagsItems(),
                ),
              ),
              _buildAddTags()
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTagsItems() {
    List<Widget> lines = [];
    userTagsList.forEach((item) {
      lines.add(
        Container(
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
                  '#' + item.tag.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    FocusScope.of(context).requestFocus(FocusNode());
                    _deleteUserTag(item);
                  });
                },
                child: Icon(
                  Icons.close,
                  color: ColorUtils.orangeAccent,
                ),
              ),
            ],
          ),
        ),
      );
    });
    return lines;
  }

  Padding _buildAddTags() {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Stack(
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
                hintText: Localization.of(context).getString('addMoreTags'),
                hintStyle: TextStyle(
                  fontSize: 14.0,
                  color: ColorUtils.darkerGray,
                ),
              ),
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
              _addTag();
            },
          ),
        ],
      ),
    );
  }

  void _showDialog(String title, String message, String buttonText) {
    setState(() {
      _saving = false;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        title: title,
        description: message,
        buttonText: buttonText,
      ),
    );
  }
}
