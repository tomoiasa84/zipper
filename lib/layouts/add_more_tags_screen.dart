import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:flutter/material.dart';

class AddMoreTagsScreen extends StatefulWidget {
  @override
  AddMoreTagsScreenState createState() => AddMoreTagsScreenState();
}

class AddMoreTagsScreenState extends State<AddMoreTagsScreen> {
  TextEditingController _addSkillsTextEditingController =
      TextEditingController();
  List<String> skills = [
    '#babysitter',
    '#keeper',
    '#nanny',
    '#caretaker',
    '#housekeeper',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 24.0),
                child: Text(
                  Localization.of(context).getString("addMoreTagsTotThePerson"),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                ),
              ),
              _buildNameCard(),
              _buildTagsCard()
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        "Name Surname",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
      ),
      centerTitle: true,
      leading: buildBackButton(() {
        Navigator.pop(context, true);
      }),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.check,
            color: ColorUtils.darkerGray,
          ),
          onPressed: () {
            Navigator.pop(context, true);
          },
        )
      ],
    );
  }

  Card _buildNameCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(
              Icons.arrow_back,
              color: ColorUtils.darkGray,
            ),
            Column(
              children: <Widget>[
                Container(
                  width: 56.0,
                  height: 56.0,
                  child: CircleAvatar(
                    child: Text(getInitials("Name Surname"),
                        style: TextStyle(color: ColorUtils.darkerGray)),
                    backgroundColor: ColorUtils.lightLightGray,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 11.0),
                  child: Text(
                    "Name Surname",
                    style: TextStyle(
                        color: ColorUtils.darkGray,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            Icon(
              Icons.arrow_forward,
              color: ColorUtils.darkGray,
            ),
          ],
        ),
      ),
    );
  }

  Card _buildTagsCard() {
    return Card(
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
                children: _buildSkillsItems(),
              ),
            ),
            _buildAddSkills()
          ],
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

  Stack _buildAddSkills() {
    return Stack(
      alignment: const Alignment(1.0, 0.0),
      children: <Widget>[
        TextFormField(
          controller: _addSkillsTextEditingController,
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
              hintText: Localization.of(context).getString('addMoreSkills'),
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
                if (_addSkillsTextEditingController.text.isNotEmpty) {
                  setState(() {
                    skills.add(_addSkillsTextEditingController.text);
                  });
                }
              });
              _addSkillsTextEditingController.clear();
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
}
