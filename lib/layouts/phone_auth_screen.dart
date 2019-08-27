import 'package:contractor_search/layouts/sms_code_verification.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/string_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorUtils.white,
        body: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            bottom: 31.0,
          ),
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height - 40,
              child: Column(
                children: <Widget>[
                  _buildLogo(),
                  _buildTitle(),
                  _buildSignUpForm(),
                  _buildContinueButton(),
                  _buildBottomTexts()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Expanded _buildTitle() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 49.0),
        child: Text(
          Strings.createAnAccount,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
      ),
    );
  }

  Container _buildLogo() {
    return Container(
      margin: const EdgeInsets.only(top: 76.0),
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

  Form _buildSignUpForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 35.0),
            child: TextFormField(
              onChanged: (value) {
                this.name = value;
              },
              decoration: _customInputDecoration(Strings.name, Icons.person),
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
                  _customInputDecoration(Strings.location, Icons.location_on),
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
              decoration:
                  _customInputDecoration(Strings.phoneNumber, Icons.phone),
              validator: (value) {
                if (value.isEmpty) {
                  return Strings.phoneNumberValidation;
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _customInputDecoration(String hint, IconData icon) {
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

  Container _buildContinueButton() {
    return Container(
      margin: const EdgeInsets.only(top: 40.0),
      width: double.infinity,
      child: RaisedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            verifyPhone();
          }
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

  Container _buildBottomTexts() {
    return Container(
      margin: const EdgeInsets.only(top: 109.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: () {},
            child: Text(
              Strings.alreadyHaveAnAccount,
              style: TextStyle(color: ColorUtils.orangeAccent, fontSize: 11.0),
            ),
          ),
          GestureDetector(
            child: Text(
              Strings.termsAndConditions,
              style: TextStyle(color: ColorUtils.orangeAccent, fontSize: 11.0),
            ),
          )
        ],
      ),
    );
  }
}
