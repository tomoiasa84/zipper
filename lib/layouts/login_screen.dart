import 'package:contractor_search/bloc/login_bloc.dart';
import 'package:contractor_search/layouts/sms_code_verification_screen.dart';
import 'package:contractor_search/layouts/terms_and_conditions_screen.dart';
import 'package:contractor_search/layouts/tutorial_screen.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/auth_type.dart';
import 'package:contractor_search/utils/custom_dialog.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Duration _timeOut = const Duration(minutes: 1);
  bool _smsCodeSent = false;
  LoginBloc _loginBloc;

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      _smsCodeSent = true;
      setState(() {
        _saving = false;
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SmsCodeVerificationScreen(
                  verificationId, "", "", phoneNumber, AuthType.login, _timeOut)));
    };

    final PhoneVerificationCompleted verifiedSuccess =
        (AuthCredential credential) {
      if (!_smsCodeSent && credential != null) {
        signIn(credential);
      } else {
        print('verified');
        setState(() {
          _saving = false;
        });
      }
    };

    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      print('${exception.message}');
      setState(() {
        _saving = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          title: Localization.of(context).getString("error"),
          description: exception.message,
          buttonText: Localization.of(context).getString("ok"),
        ),
      );
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: this.phoneNumber,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: _timeOut,
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed);
  }

  void _showDialog(String title, String description) {
    setState(() {
      _saving = false;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        title: title,
        description:
        description,
        buttonText: Localization.of(context).getString("ok"),
      ),
    );
  }

  signIn(AuthCredential credential) async {
    setState(() {
      _saving = true;
    });
    FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      final AuthResult user = await _auth.signInWithCredential(credential);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.user.uid == currentUser.uid);

      if (user != null) {
        user.user.getIdToken().then((token) {
          _loginBloc.saveAccessToken(token.token).then((token) {
            _checkUser(user);
          });
        });
      } else {
        _showDialog(
            Localization.of(context).getString('error'),
            Localization.of(context).getString('loginErrorMessage'));
      }
    } on PlatformException catch (e) {
      _showDialog(Localization.of(context).getString('error'), e.message);
    }
  }

  void _checkUser(AuthResult authResult) {
    List<User> usersList = [];
    _loginBloc.getUsers().then((result) {
      if (result.data != null) {
        final List<Map<String, dynamic>> users =
        result.data['get_users'].cast<Map<String, dynamic>>();
        users.forEach((item) {
          usersList.add(User.fromJson(item));
        });
        User user = usersList.firstWhere(
                (user) => user.phoneNumber == phoneNumber,
            orElse: () => null);

          if (user == null) {
            SharedPreferencesHelper.clear().then((_) {
              _showDialog(
                  Localization.of(context).getString('error'),
                  Localization.of(context).getString('loginErrorMessage'));
            });
          } else {
            _finishLogin(user.id, user.name);
          }
      }
    });
  }

  void _finishLogin(String userId, String userName) {
    _loginBloc.saveCurrentUserId(userId).then((userId) {
      _loginBloc.saveCurrentUserName(userName).then((value) {
        setState(() {
          _saving = false;
        });
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => TutorialScreen()),
            ModalRoute.withName("/homepage"));
      });
    });
  }

  @override
  void initState() {
    _loginBloc = LoginBloc();
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
            margin: const EdgeInsets.only(top: 25.0),
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
                        buildBackButton(Icons.arrow_back, () {
                          Navigator.pop(context, true);
                        }),
                        buildLogo(context),
                        buildTitle(Localization.of(context).getString('login'),
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
          validator: (value) {
            return validatePhoneNumber(value,
                Localization.of(context).getString('phoneNumberValidation'));
          },
          onChanged: (value) {
            this.phoneNumber = value;
          },
          decoration: customInputDecoration(
              Localization.of(context).getString('phoneNumber'), Icons.phone),
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
        }, Localization.of(context).getString('termsAndConditions')),
      ),
    );
  }

  Padding _buildButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child: customAccentButton(Localization.of(context).getString('continue'),
          () {
        FocusScope.of(context).requestFocus(FocusNode());
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
