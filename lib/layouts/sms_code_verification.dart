import 'package:contractor_search/bloc/sign_up_bloc.dart';
import 'package:contractor_search/layouts/terms_and_conditions_screen.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/string_utils.dart';
import 'package:contractor_search/utils/custom_dialog.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SmsCodeVerification extends StatefulWidget {
  String smsCode;
  String verificationId;
  String name;
  int location;

  SmsCodeVerification(
      this.smsCode, this.verificationId, this.name, this.location);

  @override
  SmsCodeVerificationState createState() => SmsCodeVerificationState();
}

class SmsCodeVerificationState extends State<SmsCodeVerification> {
  final _formKey = GlobalKey<FormState>();
  SignUpBloc _signUpBloc;

  @override
  void didChangeDependencies() {
    _signUpBloc = SignUpBloc();
    super.didChangeDependencies();
  }

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
      _signUpBloc
          .createUser(widget.name, widget.location, user.user.uid,
              user.user.phoneNumber)
          .then((result) {
        if (result.data != null) {
          User newUser = User.fromJson(
              result.data['create_user']?.cast<Map<String, dynamic>>());
          saveAccessToken(newUser.id.toString());
          goToHomePage();
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) => CustomDialog(
              title: Strings.error,
              description: result.errors[0].message,
              buttonText: Strings.ok,
            ),
          );
        }
      });
    }
  }

  goToHomePage() {
    Navigator.of(context).pushReplacementNamed('/homepage');
  }

  Future saveAccessToken(String accessToken) async {
    await SharedPreferencesHelper.saveAccessToken(accessToken);
  }

  void _login(BuildContext context) {
    FirebaseAuth.instance.currentUser().then((user) {
      if (user != null) {
        saveAccessToken(user.uid.toString());
        goToHomePage();
      } else {
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
                      buildLogo(MediaQuery.of(context).size.height * 0.097),
                      buildTitle(Strings.verificationCode,
                          MediaQuery.of(context).size.height * 0.048),
                      _buildForm(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 40.0),
                        child: customAccentButton(Strings.login, () {
                          _login(context);
                        }),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.bottomRight,
                          padding:
                              const EdgeInsets.only(right: 24.0, bottom: 31.0),
                          child: buildTermsAndConditions(() {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    TermsAndConditions()));
                          }),
                        ),
                      )
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
              customInputDecoration(Strings.typeCodeHere, Icons.dialpad),
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
