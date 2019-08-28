import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/string_utils.dart';
import 'package:flutter/material.dart';

Container buildLogo() {
  return Container(
    margin: const EdgeInsets.only(top: 100.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          "assets/images/ic_logo_orange.png",
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4.5),
          child: Text(
            Strings.logo.toUpperCase(),
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

Container buildTitle(String title) {
  return Container(
    child: Container(
      margin: const EdgeInsets.only(top: 49.0),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      ),
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

Container customAccentButton(String textButton,Function onClickAction, ) {
  return Container(
    margin: const EdgeInsets.only(top: 40.0),
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
          Strings.continueText.toUpperCase(),
          style: TextStyle(
              color: ColorUtils.white,
              fontWeight: FontWeight.bold,
              fontSize: 10.0),
        ),
      ),
    ),
  );
}

GestureDetector buildTermsAndConditions(Function onClickAction){
  return GestureDetector(
    onTap: (){
      onClickAction();
    },
    child: Text(
      Strings.termsAndConditions,
      style: TextStyle(color: ColorUtils.orangeAccent, fontSize: 11.0),
    ),
  );
}