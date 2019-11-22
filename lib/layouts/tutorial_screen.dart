import 'package:contractor_search/layouts/sync_contacts_screen.dart';
import 'package:contractor_search/model/phoneContactInput.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:contractor_search/model/sync_contacts_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contractor_search/utils/custom_dialog.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:contractor_search/bloc/sync_contacts_bloc.dart';
import 'package:contractor_search/bloc/share_selected_bloc.dart';
import 'home_page.dart';
class TutorialScreen extends StatefulWidget {
  @override
  State createState() => new TutorialScreenState();
}

class TutorialScreenState extends State<TutorialScreen> {
  final _totalDots = 3;
  int _currentPosition = 0;
  PermissionStatus _permissionStatus = PermissionStatus.unknown;
  SyncContactsBloc _syncContactsBloc;
  ShareSelectedBloc _bloc;
  List<PhoneContactInput> _syncResults;
  void initState() {
    _syncContactsBloc = SyncContactsBloc();
    _bloc = ShareSelectedBloc();
    super.initState();
  }
  void _updatePosition(int position) {
    setState(() => _currentPosition = _validPosition(position));
  }

  int _validPosition(int position) {
    if (position >= _totalDots) return 0;
    if (position < 0) return _totalDots - 1;
    return position;
  }
  List<String> _generateContactsToBeLoaded(SyncContactsModel numbers) {
    List<String> phoneContactsToBeLoaded = [];
    numbers.unjoinedContacts.forEach((contact) {
      if (contact.selected) {
        if (contact.contact.phones != null &&
            contact.contact.phones.toList().isNotEmpty) {
          if (contact.contact.phones
              .toList()
              .elementAt(0)
              .value
              .toString()
              .startsWith("+")) {
            phoneContactsToBeLoaded.add(
                contact.contact.phones.toList().elementAt(0).value.toString());
          } else {
            phoneContactsToBeLoaded.add(numbers.countryCode +
                contact.contact.phones.toList().elementAt(0).value.toString());
          }
        }
      }
    });
    return phoneContactsToBeLoaded;
  }
  List<String> _generateExistingUsers(SyncContactsModel numbers) {
    List<String> existingUsers = [];
    numbers.existingUsers.forEach((contact) {
      if (contact.phones != null && contact.phones.toList().isNotEmpty) {
        if (contact.phones
            .toList()
            .elementAt(0)
            .value
            .toString()
            .startsWith("+")) {
          existingUsers
              .add(contact.phones.toList().elementAt(0).value.toString());
        } else {
          existingUsers.add(numbers.countryCode +
              contact.phones.toList().elementAt(0).value.toString());
        }
      }
    });
    return existingUsers;
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
            Localization.of(context).getString('tutorialContent'),
            'assets/images/ic_contacts_gray_bg.png');
      case 1:
        if(_syncResults != null){
          _bloc.loadAgenda(_syncResults).then((result){
            print('Load results');
          });
        }

//        List<String> phoneContactsToBeLoaded = _generateContactsToBeLoaded(_syncResults);
//        _bloc.loadContacts(phoneContactsToBeLoaded).then((result) {
//          print('Load contacts works');
//        });
//        _bloc.loadConnections(_generateExistingUsers(_syncResults)).then((result) {
//          print('Load connections works');
//        });
        return _builtContent(
            'Lorem ipsum dolor sit',
            Localization.of(context).getString('tutorialContent'),
            'assets/images/ic_hourglass_gray_bg.png');
      case 2:
        return _builtContent(
            Localization.of(context).getString('tagYourFriends'),
            Localization.of(context).getString('tutorialContent'),
            'assets/images/ic_tag_gray_bg.png');
    }
    return _builtContent(
        Localization.of(context).getString('accessAgenda'),
        Localization.of(context).getString('tutorialContent'),
        'assets/images/ic_contacts_gray_bg.png');
  }
  Future<String> getCurrentUserId() async {
    return await SharedPreferencesHelper.getCurrentUserId();
  }

  void _syncContacts() {
    final Future<PermissionStatus> statusFuture =
    PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);

    statusFuture.then((PermissionStatus status) {
      if (status == PermissionStatus.granted) {
        getCurrentUserId().then((userId) {
          _syncContactsBloc.syncContacts(userId).then((syncResult) {
            _syncResults = syncResult;
            print('Getting sync results');
            _updatePosition(++_currentPosition);
          });
        });
      }
    });
  }
  Future<void> requestPermission(PermissionGroup permission) async {
    final List<PermissionGroup> permissions = <PermissionGroup>[permission];
    final Map<PermissionGroup, PermissionStatus> permissionRequestResult =
        await PermissionHandler().requestPermissions(permissions);
    setState(() {
      _permissionStatus = permissionRequestResult[permission];
      if (_permissionStatus == PermissionStatus.granted) {
        _syncContacts();
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
//                Navigator.pushAndRemoveUntil(
//                    context,
//                    MaterialPageRoute(
//                        builder: (context) => SyncContactsScreen()),
//                    ModalRoute.withName("/homepage"));
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(
                          syncContactsFlagRequired: true,
                        )),
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
