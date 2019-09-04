import 'package:contractor_search/bloc/authentication_bloc.dart';
import 'package:contractor_search/layouts/sms_code_verification.dart';
import 'package:contractor_search/layouts/terms_and_conditions_screen.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/string_utils.dart';
import 'package:contractor_search/utils/auth_type.dart';
import 'package:contractor_search/utils/custom_dialog.dart';
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
  AuthenticationBloc _authenticationBloc;

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
                  SmsCodeVerification(verificationId, "", 0, phoneNumber, AuthType.login)));
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

  void _login() {
    setState(() {
      _saving = true;
    });
    List<User> usersList = [];
    _authenticationBloc.getUsers().then((result) {
      if (result.data != null) {
        final List<Map<String, dynamic>> users =
        result.data['get_users'].cast<Map<String, dynamic>>();
        users.forEach((item) {
          usersList.add(User.fromJson(item));
        });
        User user = usersList.firstWhere(
                (user) => user.phoneNumber == phoneNumber,
            orElse: () => null);
        if (user != null) {
          verifyPhone();
        } else {
          _showDialog(Strings.error, Strings.loginErrorMessage, Strings.ok);
          setState(() {
            _saving = false;
          });
        }
      } else {
        _showDialog(Strings.error, Strings.loginErrorMessage, Strings.ok);
        setState(() {
          _saving = false;
        });
      }
    });
  }

  @override
  void initState() {
    _authenticationBloc = AuthenticationBloc();
    super.initState();
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
          _login();
        } else {
          setState(() {
            _autoValidate = true;
          });
        }
      }),
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
