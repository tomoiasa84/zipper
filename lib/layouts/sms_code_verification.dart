import 'package:contractor_search/bloc/authentication_bloc.dart';
import 'package:contractor_search/layouts/terms_and_conditions_screen.dart';
import 'package:contractor_search/layouts/tutorial_screen.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/string_utils.dart';
import 'package:contractor_search/utils/auth_type.dart';
import 'package:contractor_search/utils/custom_dialog.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SmsCodeVerification extends StatefulWidget {
  final String verificationId;
  final String name;
  final int location;
  final String phoneNumber;
  final int authType;

  SmsCodeVerification(this.verificationId, this.name, this.location,
      this.phoneNumber, this.authType);

  @override
  SmsCodeVerificationState createState() => SmsCodeVerificationState();
}

class SmsCodeVerificationState extends State<SmsCodeVerification> {
  final _formKey = GlobalKey<FormState>();
  AuthenticationBloc _authenticationBloc;
  String smsCode;
  bool _autoValidate = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    _authenticationBloc = AuthenticationBloc();
    super.didChangeDependencies();
  }

  signIn() async {
    setState(() {
      _saving = true;
    });
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: widget.verificationId,
      smsCode: smsCode,
    );
    FirebaseAuth _auth = FirebaseAuth.instance;
    final AuthResult user = await _auth.signInWithCredential(credential);
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.user.uid == currentUser.uid);

    if (user != null) {
      if(widget.authType == AuthType.signUp) {
        _authenticationBloc
            .createUser(widget.name, widget.location, user.user.uid,
            user.user.phoneNumber)
            .then((result) {
          setState(() {
            _saving = false;
          });
          if (result.data != null) {
            _finishLogin(User
                .fromJson(result.data['create_user'])
                .id);
          } else {
            _showDialog(Strings.error, result.errors[0].message, Strings.ok);
          }
        });
      }
      else{
        _finishLogin(user.user.uid);
      }
    }
    else{
      _showDialog(Strings.error, Strings.loginErrorMessage, Strings.ok);

    }
  }

  void _finishLogin(String userId) {
    saveAccessToken(userId).then((id) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => TutorialScreen()),
          ModalRoute.withName("/homepage"));
    });
  }

  Future saveAccessToken(String accessToken) async {
    await SharedPreferencesHelper.saveAccessToken(accessToken);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                        buildTitle(Strings.verificationCode,
                            MediaQuery.of(context).size.height * 0.048),
                        _buildForm(),
                        _buildButton(context),
                        _buildTerms(context),
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
      key: _formKey,
      child: Container(
        margin: const EdgeInsets.only(top: 35.0, left: 24.0, right: 24.0),
        child: TextFormField(
          autovalidate: _autoValidate,
          onChanged: (value) {
            smsCode = value;
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

  Padding _buildButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child: customAccentButton(Strings.login, () {
        if (_formKey.currentState.validate()) {
          FirebaseAuth.instance.currentUser().then((user) {
            signIn();
          });
        } else {
          setState(() {
            _autoValidate = true;
          });
        }
      }),
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

  void _showDialog(String title, String message, String buttonText) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        title: title,
        description: message,
        buttonText: buttonText,
      ),
    );
  }
}
