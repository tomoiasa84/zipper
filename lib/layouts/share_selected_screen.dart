import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';

class ShareSelectedContactsScreen extends StatefulWidget {
  @override
  ShareSelectedContactsScreenState createState() =>
      ShareSelectedContactsScreenState();
}

class ShareSelectedContactsScreenState
    extends State<ShareSelectedContactsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: Scaffold(
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
              child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "assets/images/ic_share_gray_bg.png",
                ),
                Container(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    Localization.of(context)
                        .getString('selectedContactsWillBeShared'),
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                          ModalRoute.withName("/homepage"));
                    },
                    color: ColorUtils.orangeAccent,
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      Localization.of(context).getString("continue"),
                      style: TextStyle(
                        color: ColorUtils.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
        ),
      ),
    );
  }
}
