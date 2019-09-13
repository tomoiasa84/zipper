import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:flutter/material.dart';

class PublicTagsScreen extends StatefulWidget {
  @override
  PublicTagsScreenState createState() => PublicTagsScreenState();
}

class PublicTagsScreenState extends State<PublicTagsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 24.0),
              child: Text(
                Localization.of(context).getString("selectedTagsWillBeShared"),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
              ),
            ),
            Expanded(
              child: _buildTagsList(),
            )
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(Localization.of(context).getString("publicTags"),
          style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      leading: buildBackButton(() {
        Navigator.pop(context, true);
      }),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.search,
            color: ColorUtils.darkerGray,
          ),
          onPressed: () {},
        )
      ],
    );
  }

  ListView _buildTagsList() {
    return ListView.builder(
        itemCount: 5,
        itemBuilder: (BuildContext context, int index) {
          return _buildListItem();
        });
  }

  Card _buildListItem() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              child: Text(getInitials("Name Surname"),
                  style: TextStyle(color: ColorUtils.darkerGray)),
              backgroundColor: ColorUtils.lightLightGray,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "#housekeeper",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Name Surname",
                    style: TextStyle(color: ColorUtils.orangeAccent),
                  )
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.add,
                    color: ColorUtils.orangeAccent,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
