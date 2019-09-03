import 'package:contractor_search/layouts/sms_code_verification.dart';
import 'package:contractor_search/layouts/terms_and_conditions_screen.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/string_utils.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:contractor_search/utils/helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  var _autoValidate = false;
  String phoneNumber;
  bool _saving = false;
  String verificationId;

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      setState(() {
        _saving = false;
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SmsCodeVerification(verificationId, "", 0)));
    };

    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential user) {
      print('verified');
    };

    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      print('${exception.message}');
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: this.phoneNumber,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: ModalProgressHUD(
        inAsyncCall: _saving,
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
                        buildBackButton(() {
                          Navigator.pop(context, true);
                        }),
                        buildLogo(MediaQuery.of(context).size.height * 0.097),
                        buildTitle(Strings.login,
                            MediaQuery.of(context).size.height * 0.048),
                        _buildForm(),
                        _buildButton(),
                        _buildTerms(context)
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Form _buildForm() {
    return Form(
      autovalidate: _autoValidate,
      key: _formKey,
      child: Container(
        margin: const EdgeInsets.only(top: 35.0, left: 24.0, right: 24.0),
        child: TextFormField(
          validator: validatePhoneNumber,
          onChanged: (value) {
            this.phoneNumber = value;
          },
          decoration: customInputDecoration(Strings.phoneNumber, Icons.phone),
        ),
      ),
    );
  }

  Expanded _buildTerms(BuildContext context) {
    return Expanded(
      child: Container(
        alignment: Alignment.bottomRight,
        padding: const EdgeInsets.only(right: 24.0, bottom: 31.0),
        child: buildTermsAndConditions(() {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => TermsAndConditions()));
        }),
      ),
    );
  }

  Padding _buildButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child: customAccentButton(Strings.continueText, () {
        if (_formKey.currentState.validate()) {
          setState(() {
            _saving = true;
          });
          verifyPhone();
        } else {
          setState(() {
            _autoValidate = true;
          });
        }
      }),
    );
  }
}
