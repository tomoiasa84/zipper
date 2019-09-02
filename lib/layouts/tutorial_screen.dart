import 'package:contractor_search/layouts/sync_contacts_screen.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/string_utils.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';

class TutorialScreen extends StatefulWidget {
  @override
  State createState() => new TutorialScreenState();
}

class TutorialScreenState extends State<TutorialScreen> {
  final _totalDots = 3;
  int _currentPosition = 0;

  void _updatePosition(int position) {
    setState(() => _currentPosition = _validPosition(position));
  }

  int _validPosition(int position) {
    if (position >= _totalDots) return 0;
    if (position < 0) return _totalDots - 1;
    return position;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _builtContainer(),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: DotsIndicator(
                dotsCount: _totalDots,
                position: _currentPosition,
                decorator: DotsDecorator(
                    activeColor: ColorUtils.orangeAccent,
                    size: Size.square(8.0)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _builtContainer() {
    switch (_currentPosition) {
      case 0:
        return _builtContent(Strings.accessAgenda, Strings.tutorialContent,
            'assets/images/ic_contacts_gray_bg.png');
      case 1:
        return _builtContent('Lorem ipsum dolor sit', Strings.tutorialContent,
            'assets/images/ic_hourglass_gray_bg.png');
      case 2:
        return _builtContent(Strings.tagYourFriends, Strings.tutorialContent,
            'assets/images/ic_tag_gray_bg.png');
    }
    return _builtContent(Strings.accessAgenda, Strings.tutorialContent,
        'assets/images/ic_contacts_gray_bg.png');
  }

  Container _builtContent(String title, String text, String imageAsset) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(
        children: <Widget>[
          _builtCard(title, text),
          Container(
            alignment: Alignment.topCenter,
            child: Image.asset(imageAsset),
          ),
          _builtButton()
        ],
      ),
    );
  }

  Container _builtCard(String title, String text) {
    return Container(
      padding: const EdgeInsets.only(bottom: 18.0, top: 37.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 44.0),
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 42.0, top: 16.0, right: 16.0, left: 16.0),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.0, color: ColorUtils.darkerGray, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Positioned _builtButton() {
    return Positioned(
      bottom: 0.0,
      right: 0.0,
      left: 0.0,
      child: Container(
        alignment: Alignment.bottomCenter,
        child: RaisedButton(
          onPressed: () {
            if (_currentPosition < 2) {
              _updatePosition(++_currentPosition);
            } else {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SyncContactsScreen()),
                  ModalRoute.withName("/homepage"));
            }
          },
          color: ColorUtils.orangeAccent,
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36.0),
            child: Text(
              Strings.continueText.toUpperCase(),
              style: TextStyle(
                  color: ColorUtils.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.0),
            ),
          ),
        ),
      ),
    );
  }
}
