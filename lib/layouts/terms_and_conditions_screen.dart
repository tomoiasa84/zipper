import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:flutter/material.dart';

class TermsAndConditions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _buildFirstTitle(context,
                  Localization.of(context).getString('termsAndConditions')),
              _buildSecondTitle(
                  Localization.of(context).getString('termsAndConditions')),
              _buildDescription(
                  Localization.of(context).getString('termsAndConditionsText')),
              _buildBottomText(Localization.of(context).getString('lastEdit'))
            ],
          ),
        ),
      ),
    );
  }

  Container _buildFirstTitle(BuildContext context, String text) {
    return Container(
      margin: const EdgeInsets.only(top: 25.0),
      child: Row(
        children: <Widget>[
          buildBackButton(() {
            Navigator.pop(context, true);
          }),
          Padding(
            padding: const EdgeInsets.only(left: 75.0, top: 8.0),
            child: Text(
              text,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.0),
            ),
          ),
        ],
      ),
    );
  }

  Container _buildSecondTitle(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 29.0, left: 32.0, right: 32.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40.0),
      ),
    );
  }

  Container _buildDescription(String description) {
    return Container(
      margin: const EdgeInsets.only(top: 17.0, left: 32.0, right: 32.0),
      child: Text(
        description,
        style: TextStyle(
            fontSize: 14.0, color: ColorUtils.darkerGray, height: 1.5),
      ),
    );
  }

  Container _buildBottomText(String text) {
    return Container(
      margin: const EdgeInsets.only(
          top: 24.0, left: 32.0, right: 32.0, bottom: 15.0),
      child: Row(
        children: <Widget>[
          Image.asset(
            'assets/images/ic_access_time.png',
            height: 18.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              text,
              style: TextStyle(fontSize: 14.0, color: ColorUtils.textGray),
            ),
          )
        ],
      ),
    );
  }
}
