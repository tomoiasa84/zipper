import 'package:contractor_search/layouts/sync_contacts_screen.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class TutorialScreen extends StatefulWidget {

  @override
  State createState() => new TutorialScreenState();
}

class TutorialScreenState extends State<TutorialScreen> {
  final _totalDots = 3;
  int _currentPosition = 0;
  PermissionStatus _permissionStatus = PermissionStatus.unknown;

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
                position: _currentPosition.toDouble(),
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
        return _builtContent(
            Localization.of(context).getString('accessAgenda'),
            Localization.of(context).getString('accessAgendaText'),
            'assets/images/ic_contacts_gray_bg.png');
      case 1:
        return _builtContent(
            Localization.of(context).getString('saveTime'),
            Localization.of(context).getString('saveTimeText'),
            'assets/images/ic_hourglass_gray_bg.png');
      case 2:
        return _builtContent(
            Localization.of(context).getString('tagYourFriends'),
            Localization.of(context).getString('tagYourFriendsText'),
            'assets/images/ic_tag_gray_bg.png');
    }
    return _builtContent(
        Localization.of(context).getString('accessAgenda'),
        Localization.of(context).getString('tutorialContent'),
        'assets/images/ic_contacts_gray_bg.png');
  }

  Future<void> requestPermission(PermissionGroup permission) async {
    final List<PermissionGroup> permissions = <PermissionGroup>[permission];
    final Map<PermissionGroup, PermissionStatus> permissionRequestResult =
        await PermissionHandler().requestPermissions(permissions);

    setState(() {
      _permissionStatus = permissionRequestResult[permission];
      if (_permissionStatus == PermissionStatus.granted) {
        _updatePosition(++_currentPosition);
      }
    });
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
              padding:
                  const EdgeInsets.only(top: 44.0, left: 16.0, right: 16.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
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
            switch (_currentPosition) {
              case 0:
                requestPermission(PermissionGroup.contacts);
                break;
              case 2:
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SyncContactsScreen()),
                    ModalRoute.withName("/homepage"));
                break;
              default:
                _updatePosition(++_currentPosition);
            }
          },
          color: ColorUtils.orangeAccent,
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36.0),
            child: Text(
              Localization.of(context).getString('continue').toUpperCase(),
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
