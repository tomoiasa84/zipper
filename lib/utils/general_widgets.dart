import 'package:contractor_search/model/review.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/star_display.dart';
import 'package:flutter/material.dart';

Container buildLogo(BuildContext context) {
  return Container(
    margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.097),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          "assets/images/ic_logo_orange.png",
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4.5),
          child: Text(
            Localization.of(context).getString('logo').toUpperCase(),
            style: TextStyle(
                fontFamily: 'GothamRounded',
                fontWeight: FontWeight.bold,
                fontSize: 35.0),
          ),
        )
      ],
    ),
  );
}

Container buildTitle(String title, double marginTop) {
  return Container(
    margin: EdgeInsets.only(top: marginTop),
    child: Text(
      title,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
    ),
  );
}

InputDecoration customInputDecoration(String hint, IconData icon) {
  return InputDecoration(
    focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: ColorUtils.orangeAccent)),
    enabledBorder: new UnderlineInputBorder(
        borderSide: BorderSide(color: ColorUtils.lightBlue)),
    prefixIcon: Icon(
      icon,
      color: ColorUtils.orangeAccent,
    ),
    hintText: hint,
    hintStyle: TextStyle(fontSize: 14.0, color: ColorUtils.darkerGray),
  );
}

Container customAccentButton(
  String textButton,
  Function onClickAction,
) {
  return Container(
    width: double.infinity,
    child: RaisedButton(
      onPressed: () {
        onClickAction();
      },
      color: ColorUtils.orangeAccent,
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Text(
          textButton.toUpperCase(),
          style: TextStyle(
              color: ColorUtils.white,
              fontWeight: FontWeight.bold,
              fontSize: 10.0),
        ),
      ),
    ),
  );
}

GestureDetector buildTermsAndConditions(Function onClickAction, String text) {
  return GestureDetector(
    onTap: () {
      onClickAction();
    },
    child: Text(
      text,
      style: TextStyle(color: ColorUtils.orangeAccent, fontSize: 11.0),
    ),
  );
}

GestureDetector buildBackButton(IconData iconData, Function onClickAction) {
  return GestureDetector(
    child: Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.only(
          left: 10.0, top: 16.0, right: 10.0, bottom: 10.0),
      child: Icon(
        iconData,
        color: ColorUtils.darkGray,
      ),
    ),
    onTap: () {
      onClickAction();
    },
  );
}


List<Widget> generateSkills(List<Review> reviews) {
  List<Widget> skills = [];
  reviews.forEach((item) {
    skills.add(Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: ColorUtils.lightLightGray),
                borderRadius: BorderRadius.all(Radius.circular(6.0))),
            padding: const EdgeInsets.only(
                top: 8.0, bottom: 8.0, left: 16.0, right: 10.0),
            child: Text(item.text),
          ),
          Row(
            children: <Widget>[
              StarDisplay(
                value: item.stars,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  item.stars.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ],
      ),
    ));
  });
  return skills;
}