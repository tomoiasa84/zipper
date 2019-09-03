import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/string_utils.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:flutter/material.dart';

class TermsAndConditions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: Scaffold(
        body: Container(
          margin: const EdgeInsets.symmetric(vertical: 39.0),
          child: Column(
            children: <Widget>[
              _buildFirstTitle(context),
              _buildSecondTitle(),
              _buildDescription(),
              _buildBottomText()
            ],
          ),
        ),
      ),
    );
  }

  Row _buildFirstTitle(BuildContext context) {
    return Row(
      children: <Widget>[
        buildBackButton(() {
          Navigator.pop(context, true);
        }),
        Padding(
          padding: const EdgeInsets.only(left: 75.0, top: 8.0),
          child: Text(
            Strings.termsAndConditions,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
          ),
        ),
      ],
    );
  }

  Container _buildSecondTitle() {
    return Container(
      margin: const EdgeInsets.only(top: 29.0, left: 32.0, right: 32.0),
      child: Text(
        Strings.termsAndConditions,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40.0),
      ),
    );
  }

  Container _buildDescription() {
    return Container(
      margin: const EdgeInsets.only(top: 17.0, left: 32.0, right: 32.0),
      child: Text(
        Strings.termsAndConditionsText,
        style: TextStyle(
            fontSize: 14.0, color: ColorUtils.darkerGray, height: 1.5),
      ),
    );
  }

  Container _buildBottomText() {
    return Container(
      margin: const EdgeInsets.only(top: 24.0, left: 32.0, right: 32.0),
      child: Row(
        children: <Widget>[
          Image.asset(
            'assets/images/ic_access_time.png',
            height: 18.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              Strings.lastEdit,
              style: TextStyle(fontSize: 14.0, color: ColorUtils.textGray),
            ),
          )
        ],
      ),
    );
  }
}
