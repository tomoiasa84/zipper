import 'package:contractor_search/layouts/login_screen.dart';
import 'package:contractor_search/layouts/sms_code_verification.dart';
import 'package:contractor_search/layouts/terms_and_conditions_screen.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/string_utils.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  PhoneAuthScreenState createState() {
    return PhoneAuthScreenState();
  }
}

class PhoneAuthScreenState extends State<PhoneAuthScreen> {
  String phoneNo;
  String smsCode;
  String name;
  String location;
  String verificationId;
  final _formKey = GlobalKey<FormState>();

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };
    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SmsCodeVerification(smsCode, verificationId)));
    };

    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential user) {
      print('verified');
    };

    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      print('${exception.message}');
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: this.phoneNo,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed);
  }

  String _validatePhoneNumber(String value) {
    final RegExp phoneExp = RegExp(r'^\(\d\d\d\) \d\d\d\-\d\d\d\d$');
    if (!phoneExp.hasMatch(value)) return Strings.phoneNumberValidation;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: Scaffold(
        backgroundColor: ColorUtils.white,
        body: Container(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 31.0),
          height: double.infinity,
          child: LayoutBuilder(builder: (context, constraint) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraint.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    buildLogo(MediaQuery.of(context).size.height * 0.097),
                    buildTitle(Strings.createAnAccount, 0),
                    _buildSignUpForm(),
                    customAccentButton(Strings.continueText, () {
                      if (_formKey.currentState.validate()) {
                        verifyPhone();
                      }
                    }),
                    _buildBottomTexts()
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Form _buildSignUpForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Container(
            child: TextFormField(
              onChanged: (value) {
                this.name = value;
              },
              decoration: customInputDecoration(Strings.name, Icons.person),
              validator: (value) {
                if (value.isEmpty) {
                  return Strings.nameValidation;
                }
                return null;
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 35.0),
            child: TextFormField(
              onChanged: (value) {
                this.location = value;
              },
              decoration:
                  customInputDecoration(Strings.location, Icons.location_on),
              validator: (value) {
                if (value.isEmpty) {
                  return Strings.locationValidation;
                }
                return null;
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 35.0),
            child: TextFormField(
              onChanged: (value) {
                this.phoneNo = value;
              },
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly,
              ],
              decoration:
                  customInputDecoration(Strings.phoneNumber, Icons.phone),
              validator: _validatePhoneNumber,
            ),
          ),
        ],
      ),
    );
  }

  Container _buildBottomTexts() {
    return Container(
      alignment: Alignment.bottomRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      LoginScreen()));
            },
            child: Text(
              Strings.alreadyHaveAnAccount,
              style: TextStyle(
                  color: ColorUtils.orangeAccent,
                  fontSize: 11.0),
            ),
          ),
          buildTermsAndConditions(() {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) =>
                    TermsAndConditions()));
          }),
        ],
      ),
    );
  }
}
