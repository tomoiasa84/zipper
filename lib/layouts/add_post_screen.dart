import 'package:contractor_search/bloc/add_post_bloc.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class AddPostScreen extends StatefulWidget {
  @override
  AddPostScreenState createState() => AddPostScreenState();
}

class AddPostScreenState extends State<AddPostScreen> {
  AddPostBloc _addPostBloc;
  TextEditingController _addTagsTextEditingController = TextEditingController();
  bool _saving = false;
  User _user;
  List<String> skills = [
    '#babysitter',
    '#keeper',
  ];

  @override
  void initState() {
    _getCurrentUserInfo();
    super.initState();
  }

  void _getCurrentUserInfo() {
    _addPostBloc = AddPostBloc();
    setState(() {
      _saving = true;
    });
    getCurrentUserId().then((userId) {
      _addPostBloc.getCurrentUser(userId).then((result) {
        if (result.data != null) {
          setState(() {
            _user = User.fromJson(result.data['get_user']);
            _saving = false;
          });
        }
      });
    });
  }

  Future<String> getCurrentUserId() async {
    return await SharedPreferencesHelper.getCurrentUserId();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _saving,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: (_user != null)
            ? SingleChildScrollView(
                child: Column(
                  children: <Widget>[_buildPreviewCard(), _buildTagsCard()],
                ),
              )
            : Container(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: Text(
        Localization.of(context).getString('addPost'),
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      leading: buildBackButton(Icons.clear, () {
        Navigator.pop(context, false);
      }),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.check,
            color: ColorUtils.darkGray,
          ),
          onPressed: () {
            Navigator.pop(context, false);
          },
        )
      ],
    );
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
                  children: _buildSkillsItems(),
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
              Text(item),
              GestureDetector(
                onTap: () {
                  setState(() {
                    skills.remove(item);
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

  Padding _buildNameRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            child: Text(getInitials(_user.name),
                style: TextStyle(color: ColorUtils.darkerGray)),
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
                      text: _user.name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorUtils.textBlack),
                      children: <TextSpan>[
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
                    "#babysitter #keeper",
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
        TextFormField(
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
        Container(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (_addTagsTextEditingController.text.isNotEmpty) {
                  setState(() {
                    skills.add(_addTagsTextEditingController.text);
                  });
                }
              });
              _addTagsTextEditingController.clear();
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Text(
              Localization.of(context).getString('add'),
              style: TextStyle(
                  color: ColorUtils.orangeAccent, fontWeight: FontWeight.bold),
            ),
          ),
        )
      ],
    );
  }

  Container _buildDetailsTextFiled() {
    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      child: TextFormField(
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
