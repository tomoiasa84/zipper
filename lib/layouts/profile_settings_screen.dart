import 'package:contractor_search/bloc/profile_settings_bloc.dart';
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
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final User user;

  ProfileSettingsScreen(this.user);

  @override
  ProfileSettingsScreenState createState() => ProfileSettingsScreenState();
}

class ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool _saving = false;
  ProfileSettingsBloc _profileSettingsBloc;
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  TextEditingController _nameTextEditingController = TextEditingController();
  TextEditingController _mainTextEditingController = TextEditingController();
  TextEditingController _bioTextEditingController = TextEditingController();
  TextEditingController _addSkillsTextEditingController =
      TextEditingController();
  String name;
  List<UserTag> skills = [];
  List<Tag> tagsList = [];

  UserTag userTag;

  void getTags() {
    _profileSettingsBloc.getTags().then((result) {
      if (result.data != null) {
        final List<Map<String, dynamic>> tags =
            result.data['get_tags'].cast<Map<String, dynamic>>();
        tags.forEach((item) {
          var tagItem = Tag.fromJson(item);
          if (skills.isNotEmpty) {
            var tagFound = skills.firstWhere((tag) => tag.tag.id == tagItem.id,
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
    _profileSettingsBloc
        .updateUser(
            _nameTextEditingController.text,
            widget.user.location.id,
            widget.user.id,
            widget.user.phoneNumber,
            true,
            _bioTextEditingController.text)
        .then((result) {
      setState(() {
        _saving = false;
      });
      if (result.errors == null) {
        Navigator.pop(context);
      } else {
        _showDialog(Localization.of(context).getString('error'),
            result.errors[0].message, Localization.of(context).getString('ok'));
      }
    });
  }

  @override
  void initState() {
    _profileSettingsBloc = ProfileSettingsBloc();
    getTags();
    widget.user.tags.forEach((item) {
      if (item.defaultTag) {
        userTag = item;
        skills.add(item);
      }
    });
    _nameTextEditingController.value =
        new TextEditingValue(text: widget.user.name);
    _mainTextEditingController.value = new TextEditingValue(
        text: (userTag != null) ? '#' + userTag.tag.name : "");
    _bioTextEditingController.value = new TextEditingValue(
        text: widget.user.description != null ? widget.user.description : "");
    name = widget.user.name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
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
                  _buildSkills(),
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
        style: TextStyle(fontWeight: FontWeight.bold),
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

  void _showDialog(String title, String message, String buttonText) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        title: title,
        description: message,
        buttonText: buttonText,
      ),
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

  Row _buildProfilePictureRow() {
    return Row(
      children: <Widget>[
        CircleAvatar(
          child: Text(getInitials(widget.user.name),
              style: TextStyle(color: ColorUtils.darkerGray)),
          backgroundColor: ColorUtils.lightLightGray,
        ),
        GestureDetector(
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              Localization.of(context).getString('changeProfilePhoto'),
              style: TextStyle(color: ColorUtils.orangeAccent),
            ),
          ),
          onTap: () {},
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
                List<String> list = [];
                tagsList
                    .where((it) => it.name.startsWith(pattern))
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
              validator: (value) {
                if (value.isEmpty) {
                  return Localization.of(context).getString('tagValidation');
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Container _buildSkills() {
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
                Localization.of(context).getString('skills'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 16.0),
                child: Wrap(
                  direction: Axis.horizontal,
                  children: _buildSkillsItems(),
                ),
              ),
              _buildAddSkills()
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSkillsItems() {
    List<Widget> lines = []; // this will hold Rows according to available lines
    skills.forEach((item) {
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

  Padding _buildAddSkills() {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Stack(
        alignment: const Alignment(1.0, 0.0),
        children: <Widget>[
          TypeAheadFormField(
            getImmediateSuggestions: true,
            textFieldConfiguration: TextFieldConfiguration(
              controller: _addSkillsTextEditingController,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    borderSide: BorderSide(
                        color: ColorUtils.lightLightGray, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    borderSide: BorderSide(
                        color: ColorUtils.lightLightGray, width: 1.0),
                  ),
                  hintText: Localization.of(context).getString('addMoreSkills'),
                  hintStyle: TextStyle(
                    fontSize: 14.0,
                    color: ColorUtils.darkerGray,
                  ),
                  suffix: Text('          ')),
            ),
            suggestionsCallback: (pattern) {
              List<String> list = [];
              tagsList
                  .where((it) => it.name.startsWith(pattern))
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
              this._addSkillsTextEditingController.text = '#' + suggestion;
            },
            validator: (value) {
              if (value.isEmpty) {
                return Localization.of(context).getString('locationValidation');
              }
              return null;
            },
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (_addSkillsTextEditingController.text.isNotEmpty) {
                    _createNewUserTag();
                  }
                });
                _addSkillsTextEditingController.clear();
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Text(
                Localization.of(context).getString('add'),
                style: TextStyle(
                    color: ColorUtils.orangeAccent,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _createNewUserTag() {
    setState(() {
      _saving = true;
    });
    Tag tag = tagsList.firstWhere(
        (tag) => tag.name == _addSkillsTextEditingController.text.substring(1),
        orElse: () => null);
    if (tag != null) {
      _profileSettingsBloc.createUserTag(widget.user.id, tag.id).then((result) {
        setState(() {
          _saving = false;
        });
        if (result.errors == null) {
          setState(() {
            tagsList.remove(tag);
            skills.add(UserTag.fromJson(result.data['create_userTag']));
          });
        } else {
          _showDialog(
              Localization.of(context).getString("error"),
              result.errors[0].message,
              Localization.of(context).getString("ok"));
        }
      });
    }
  }

  void _deleteUserTag(UserTag item) {
    setState(() {
      _saving = true;
    });
    _profileSettingsBloc.deleteUserTag(item.id).then((result) {
      setState(() {
        _saving = false;
      });
      if (result.errors == null) {
        setState(() {
          tagsList.add(item.tag);
          skills.remove(item);
        });
      }
    });
  }
}
