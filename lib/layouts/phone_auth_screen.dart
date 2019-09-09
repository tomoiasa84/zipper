import 'package:contractor_search/layouts/login_screen.dart';
import 'package:contractor_search/layouts/sms_code_verification.dart';
import 'package:contractor_search/layouts/terms_and_conditions_screen.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/auth_type.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:contractor_search/utils/helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  PhoneAuthScreenState createState() {
    return PhoneAuthScreenState();
  }
}

class PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  String phoneNumber;
  String name;
  String location;
  String verificationId;
  bool _autoValidate = false;
  bool _saving = false;

  Future<void> verifyPhone(int authType) async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      setState(() {
        _saving = false;
      });
      this.verificationId = verId;
      goToSmsVerificationPage(authType);
    };

    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential user) {
      setState(() {
        _saving = false;
      });
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

  void goToSmsVerificationPage(int authType) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SmsCodeVerification(
                verificationId, name, location, phoneNumber, authType)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Scaffold(
          backgroundColor: ColorUtils.white,
          body: Container(
            padding:
                const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 31.0),
            height: double.infinity,
            child: LayoutBuilder(builder: (context, constraint) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraint.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      buildLogo(context),
                      buildTitle(
                          Localization.of(context).getString('createAnAccount'),
                          0),
                      _buildSignUpForm(),
                      customAccentButton(
                          Localization.of(context).getString('continue'), () {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            _saving = true;
                          });
                          verifyPhone(AuthType.signUp);
                        } else {
                          setState(() {
                            _autoValidate = true;
                          });
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
      ),
    );
  }

  Form _buildSignUpForm() {
    return Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: Column(
        children: <Widget>[
          _buildNameTextField(),
          _buildLocationTextField(),
          _buildPhoneNoTextField(),
        ],
      ),
    );
  }

  Container _buildNameTextField() {
    return Container(
      child: TextFormField(
        onChanged: (value) {
          this.name = value;
        },
        decoration: customInputDecoration(
            Localization.of(context).getString('name'), Icons.person),
        validator: (value) {
          if (value.isEmpty) {
            return Localization.of(context).getString('nameValidation');
          }
          return null;
        },
      ),
    );
  }

  Container _buildLocationTextField() {
    return Container(
        margin: const EdgeInsets.only(top: 35.0),
        child:
            TextFormField(
          onChanged: (value) {
            this.location = value;
          },
          decoration: customInputDecoration(
              Localization.of(context).getString('location'),
              Icons.location_on),
          validator: (value) {
            if (value.isEmpty) {
              return Localization.of(context).getString('locationValidation');
            }
            return null;
          },
        ));
  }

  Container _buildPhoneNoTextField() {
    return Container(
      margin: const EdgeInsets.only(top: 35.0),
      child: TextFormField(
        onChanged: (value) {
          this.phoneNumber = value;
        },
        validator: (value) {
          return validatePhoneNumber(value,
              Localization.of(context).getString('phoneNumberValidation'));
        },
        decoration: customInputDecoration(
            Localization.of(context).getString('phoneNumberHint'), Icons.phone),
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
                  builder: (BuildContext context) => LoginScreen()));
            },
            child: Text(
              Localization.of(context).getString('alreadyRegisteredQuestion'),
              style: TextStyle(color: ColorUtils.orangeAccent, fontSize: 11.0),
            ),
          ),
          buildTermsAndConditions(() {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => TermsAndConditions()));
          }, Localization.of(context).getString('termsAndConditions')),
        ],
      ),
    );
  }
}
