import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/string_utils.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SmsCodeVerification extends StatefulWidget {
  String smsCode;
  String verificationId;

  SmsCodeVerification(this.smsCode, this.verificationId);

  @override
  SmsCodeVerificationState createState() => SmsCodeVerificationState();
}

class SmsCodeVerificationState extends State<SmsCodeVerification> {
  final _formKey = GlobalKey<FormState>();

  signIn() async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: widget.verificationId,
      smsCode: widget.smsCode,
    );
    FirebaseAuth _auth = FirebaseAuth.instance;

    final AuthResult user = await _auth.signInWithCredential(credential);
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.user.uid == currentUser.uid);

    if (user != null) {
      saveAccessToken(user.user.uid);
      Navigator.of(context).pushReplacementNamed('/homepage');
    }
  }

  Future saveAccessToken(String accessToken) async {
    await SharedPreferencesHelper.saveAccessToken(accessToken);
  }

  void _login(BuildContext context) {
    FirebaseAuth.instance.currentUser().then((user) {
      if (user != null) {
        saveAccessToken(user.uid);
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacementNamed('/homepage');
      } else {
        Navigator.of(context).pop();
        signIn();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorUtils.white,
        body: Container(
          height: double.infinity,
          child: LayoutBuilder(builder: (context, constraint) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraint.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _buildBackButton(),
                      buildLogo(),
                      buildTitle(Strings.verificationCode),
                      _buildForm(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: customAccentButton(Strings.login, () {
                          _login(context);
                        }),
                      ),
                      Expanded(
                        child: Container(
                            alignment: Alignment.bottomRight,
                            padding: const EdgeInsets.only(
                                right: 24.0, bottom: 31.0),
                            child: buildTermsAndConditions()),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  GestureDetector _buildBackButton() {
    return GestureDetector(
      child: Container(
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.only(
            left: 10.0, top: 16.0, right: 10.0, bottom: 10.0),
        child: Icon(
          Icons.arrow_back,
          color: ColorUtils.darkGray,
        ),
      ),
      onTap: () {
        Navigator.pop(context, true);
      },
    );
  }

  Form _buildForm() {
    return Form(
      key: _formKey,
      child: Container(
        margin: const EdgeInsets.only(top: 35.0, left: 24.0, right: 24.0),
        child: TextFormField(
          onChanged: (value) {
            widget.smsCode = value;
          },
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter.digitsOnly,
          ],
          decoration:
              customInputDecoration(Strings.verificationCode, Icons.phone),
          validator: (value) {
            if (value.isEmpty) {
              return Strings.verificationCodeValidation;
            }
            return null;
          },
        ),
      ),
    );
  }
}
