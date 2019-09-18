import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SelectContactScreen extends StatefulWidget {
  SelectContactScreen({Key key}) : super(key: key);

  @override
  _SelectContactScreenState createState() => _SelectContactScreenState();
}

class _SelectContactScreenState extends State<SelectContactScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _loading,
      child: Scaffold(
        body: new Column(children: <Widget>[
          AppBar(
            title: Text(
              Localization.of(context).getString('shareContact'),
              style: TextStyle(
                  color: ColorUtils.textBlack,
                  fontSize: 14,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
          ),
          _showContacts(),
        ]),
      ),
    );
  }

  Widget _showContacts() {
    return Expanded(
      child: Container(
        color: ColorUtils.messageGray,
        child: new Container(margin: EdgeInsets.fromLTRB(16, 16, 16, 16)),
      ),
    );
  }
}
