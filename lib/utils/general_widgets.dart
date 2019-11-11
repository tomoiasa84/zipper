import 'package:auto_size_text/auto_size_text.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/model/user_tag.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/star_display.dart';
import 'package:flutter/material.dart';

import 'general_methods.dart';

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

List<Widget> generateTags(List<UserTag> userTag, Function onTapAction,
    Function onStarsTapAction, String noReviewsMessage) {
  List<Widget> tags = [];
  userTag.forEach((item) {
    tags.add(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: GestureDetector(
                onTap: () {
                  onTapAction(item.id);
                },
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: ColorUtils.lightLightGray),
                        borderRadius: BorderRadius.all(Radius.circular(6.0))),
                    padding: const EdgeInsets.only(
                        top: 8.0, bottom: 8.0, left: 16.0, right: 10.0),
                    child: AutoSizeText(
                      '#' + item.tag.name,
                      style: TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
              ),
            ),
            item.reviews.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      onStarsTapAction(item.reviews);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        StarDisplay(
                          value: item.score,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            item.score.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ))
                : Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(noReviewsMessage),
                  ),
          ],
        ),
      ),
    );
  });
  if (tags.length > 5) {
    return tags.sublist(0, 5);
  } else {
    return tags;
  }
}

Widget generateContactUI(
    User userRec,
    User userSend,
    String tagName,
    int score,
    Function clickAction,
    String bottomDescription,
    Function goToUserDetailsScreen) {
  return Container(
    padding: const EdgeInsets.only(top: 16.0),
    child: Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 28.0),
              decoration: getRoundedOrangeDecoration(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(48.0, 18.0, 18.0, 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              goToUserDetailsScreen(userRec);
                            },
                            child: Text(
                              userRec.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: ColorUtils.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              tagName.length > 0
                                  ? Flexible(
                                      child: Text(
                                        '#' + tagName,
                                        overflow: TextOverflow.clip,
                                        style:
                                            TextStyle(color: ColorUtils.white),
                                      ),
                                    )
                                  : Container(),
                              score != -1
                                  ? Padding(
                                      padding: EdgeInsets.fromLTRB(45, 0, 0, 0),
                                      child: Icon(
                                        Icons.star,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    )
                                  : Container(),
                              score != -1
                                  ? Text(score.toString(),
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.white))
                                  : Container()
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 4.0),
                      decoration: getRoundWhiteCircle(),
                      child: new IconButton(
                        onPressed: clickAction,
                        icon: Image.asset(
                          "assets/images/ic_inbox_orange.png",
                          color: ColorUtils.messageOrange,
                        ),
                      ),
                      width: 40,
                      height: 40,
                    )
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
              width: 56,
              height: 56,
              decoration: new BoxDecoration(shape: BoxShape.circle),
              child: CircleAvatar(
                child: userRec.profilePicUrl == null ||
                        userRec.profilePicUrl.isEmpty
                    ? Text(
                        userRec.name.startsWith('+')
                            ? '+'
                            : getInitials(userRec.name),
                        style: TextStyle(color: ColorUtils.darkerGray))
                    : null,
                backgroundImage: userRec.profilePicUrl != null &&
                        userRec.profilePicUrl.isNotEmpty
                    ? NetworkImage(userRec.profilePicUrl)
                    : null,
                backgroundColor: ColorUtils.lightLightGray,
              ),
            )
          ],
        ),
        Visibility(
          visible: bottomDescription != null,
          child: Container(
              margin: const EdgeInsets.only(top: 8.0),
              alignment: Alignment.centerRight,
              child: bottomDescription != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          bottomDescription,
                          style: TextStyle(
                              fontSize: 12.0, color: ColorUtils.almostBlack),
                        ),
                        GestureDetector(
                          onTap: () {
                            goToUserDetailsScreen(userSend);
                          },
                          child: Text(
                            userSend.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.0,
                                color: ColorUtils.almostBlack),
                          ),
                        )
                      ],
                    )
                  : Container()),
        ),
      ],
    ),
  );
}

BoxDecoration getRoundedWhiteDecoration() {
  return BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(8)));
}

BoxDecoration getRoundWhiteCircle() {
  return BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20)));
}

BoxDecoration getRoundedOrangeDecoration() {
  return BoxDecoration(
      color: ColorUtils.messageOrange,
      borderRadius: BorderRadius.all(Radius.circular(8)));
}

Center buildNoInternetMessage(String message){
  return Center(
    child: Text(message),
  );
}