import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/string_utils.dart';
import 'package:flutter/material.dart';

class TermsAndConditions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: Scaffold(
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 31.0, vertical: 39.0),
          child: Column(
            children: <Widget>[
              Text(
                Strings.termsAndConditions,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
              ),
              Container(
                margin: const EdgeInsets.only(top: 29.0),
                child: Text(
                  Strings.termsAndConditions,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40.0),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 17.0),
                child: Text(
                  Strings.termsAndConditionsText,
                  style:
                      TextStyle(fontSize: 14.0, color: ColorUtils.darkerGray),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 24.0),
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
                        style: TextStyle(
                            fontSize: 14.0, color: ColorUtils.textGray),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
