import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/helper.dart';
import 'package:flutter/material.dart';

class UserDetailsScreen extends StatefulWidget {
  final User user;

  UserDetailsScreen(this.user);

  @override
  UserDetailsScreenState createState() => UserDetailsScreenState();
}

class UserDetailsScreenState extends State<UserDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
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
                            left: 16.0, right: 16.0, top: 24.0, bottom: 44.0),
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
                      bottom: 0.0, right: 0.0, child: _buildActionsButtons()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
        centerTitle: true,
        title: Text(
          widget.user.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: ColorUtils.darkerGray,
          ),
          onPressed: () => Navigator.pop(context, false),
        ));
  }

  Container _buildDescription() {
    return Container(
      padding: const EdgeInsets.only(top: 16.0),
      child: Text(
        Localization.of(context).getString('termsAndConditionsText'),
        style: TextStyle(fontSize: 14.0, color: ColorUtils.darkerGray),
      ),
    );
  }

  Widget _buildNameRow() {
    return Row(
      children: <Widget>[
        CircleAvatar(
          child: Text(getInitials(widget.user.name),
              style: TextStyle(color: ColorUtils.darkerGray)),
          backgroundColor: ColorUtils.lightLightGray,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.user.name,
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
