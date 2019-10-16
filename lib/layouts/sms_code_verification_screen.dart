import 'dart:async';

import 'package:contractor_search/bloc/sms_code_verification_bloc.dart';
import 'package:contractor_search/layouts/terms_and_conditions_screen.dart';
import 'package:contractor_search/layouts/tutorial_screen.dart';
import 'package:contractor_search/model/location.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/auth_type.dart';
import 'package:contractor_search/utils/custom_dialog.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SmsCodeVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String name;
  final String location;
  final String phoneNumber;
  final int authType;
  final Duration timeOut;
  final Function resendVerificationCode;

  SmsCodeVerificationScreen(this.verificationId, this.name, this.location,
      this.phoneNumber, this.authType, this.timeOut, this.resendVerificationCode);

  @override
  SmsCodeVerificationScreenState createState() =>
      SmsCodeVerificationScreenState();
}

class SmsCodeVerificationScreenState extends State<SmsCodeVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  SmsCodeVerificationBloc _smsCodeVerificationBloc;
  String smsCode;
  bool _autoValidate = false;
  bool _saving = false;
  Timer _codeTimer;
  String verificationId;
  bool _codeTimedOut = false;
  TextEditingController _codeTextEditingController = TextEditingController();

  signIn() async {
    setState(() {
      _saving = true;
    });
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: widget.verificationId,
      smsCode: smsCode,
    );
    FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      final AuthResult user = await _auth.signInWithCredential(credential);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.user.uid == currentUser.uid);

      if (user != null) {
        user.user.getIdToken().then((token) {
          _smsCodeVerificationBloc.saveAccessToken(token.token).then((token) {
            _checkUser(user);
          });
        });
      } else {
        _showDialog(Localization.of(context).getString('error'),
            Localization.of(context).getString('loginErrorMessage'));
      }
    } on PlatformException catch (e) {
      _showDialog(Localization.of(context).getString('error'), e.message);
    }
  }

  void _checkUser(AuthResult authResult) {
    List<User> usersList = [];
    _smsCodeVerificationBloc.getUsers().then((result) {
      if (result.errors == null) {
        final List<Map<String, dynamic>> users =
            result.data['get_users'].cast<Map<String, dynamic>>();
        users.forEach((item) {
          usersList.add(User.fromJson(item));
        });
        User user = usersList.firstWhere(
            (user) =>
                user.phoneNumber.replaceAll(new RegExp(r"\s+\b|\b\s"), "") ==
                widget.phoneNumber.replaceAll(new RegExp(r"\s+\b|\b\s"), ""),
            orElse: () => null);

        if (widget.authType == AuthType.signUp) {
          if (user == null) {
            _signUp(authResult);
          } else if (!user.isActive) {
            _doUpdateUser(authResult);
          } else {
            SharedPreferencesHelper.clear().then((_) {
              _showDialog(Localization.of(context).getString('error'),
                  Localization.of(context).getString('alreadySignedUp'));
            });
          }
        } else if (widget.authType == AuthType.login) {
          if (user == null) {
            SharedPreferencesHelper.clear().then((_) {
              _showDialog(Localization.of(context).getString('error'),
                  Localization.of(context).getString('loginErrorMessage'));
            });
          } else {
            _finishLogin(user.id, user.name);
          }
        }
      } else {
        _showDialog(Localization.of(context).getString("error"),
            result.errors[0].message);
      }
    });
  }

  void _signUp(AuthResult user) {
    List<LocationModel> locations = [];
    _smsCodeVerificationBloc.getLocations().then((result) {
      setState(() {
        (result.data['get_locations']?.cast<Map<String, dynamic>>())?.forEach(
            (location) => locations.add(LocationModel.fromJson(location)));
        var loc = locations.firstWhere(
            (location) => location.city == widget.location,
            orElse: () => null);
        if (loc != null) {
          _createUser(user, loc.id);
        } else {
          _smsCodeVerificationBloc
              .createLocation(widget.location)
              .then((result) {
            if (result.errors == null) {
              _createUser(user,
                  LocationModel.fromJson(result.data['create_location']).id);
            } else {
              _showDialog(Localization.of(context).getString('error'),
                  result.errors[0].message);
            }
          });
        }
      });
    });
  }

  void _createUser(AuthResult user, int locationId) {
    _smsCodeVerificationBloc
        .createUser(
            widget.name, locationId, user.user.uid, user.user.phoneNumber)
        .then((result) {
      setState(() {
        _saving = false;
      });
      if (result.errors == null) {
        User user = User.fromJson(result.data['create_user']);
        _finishLogin(user.id, user.name);
      } else {
        SharedPreferencesHelper.clear().then((_) {
          _showDialog(Localization.of(context).getString('error'),
              result.errors[0].message);
        });
      }
    });
  }

  void _doUpdateUser(AuthResult user) {
    List<LocationModel> locations = [];
    _smsCodeVerificationBloc.getLocations().then((result) {
      setState(() {
        (result.data['get_locations']?.cast<Map<String, dynamic>>())?.forEach(
            (location) => locations.add(LocationModel.fromJson(location)));
        var loc = locations.firstWhere(
            (location) => location.city == widget.location,
            orElse: () => null);
        if (loc != null) {
          _updateUserData(user, loc.id);
        } else {
          _smsCodeVerificationBloc
              .createLocation(widget.location)
              .then((result) {
            if (result.errors == null) {
              _updateUserData(user,
                  LocationModel.fromJson(result.data['create_location']).id);
            } else {
              _showDialog(Localization.of(context).getString('error'),
                  result.errors[0].message);
            }
          });
        }
      });
    });
  }

  void _updateUserData(AuthResult user, int locationId) {
    _smsCodeVerificationBloc
        .updateUser(
            widget.name, locationId, user.user.uid, user.user.phoneNumber, true)
        .then((result) {
      setState(() {
        _saving = false;
      });
      if (result.errors != null) {
        User user = User.fromJson(result.data['update_user']);
        _finishLogin(user.id, user.name);
      } else {
        SharedPreferencesHelper.clear().then((_) {
          _showDialog(Localization.of(context).getString('error'),
              result.errors[0].message);
        });
      }
    });
  }

  void _finishLogin(String userId, String userName) {
    _smsCodeVerificationBloc.saveCurrentUserId(userId).then((userId) {
      _smsCodeVerificationBloc.saveCurrentUserName(userName).then((value) {
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
    _smsCodeVerificationBloc = SmsCodeVerificationBloc();
    verificationId = widget.verificationId;
    _codeTimer = Timer(widget.timeOut, () {
      if (mounted) {
        setState(() {
          _codeTimedOut = true;
        });
      }
    });
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
            margin: const EdgeInsets.only(top: 25.0),
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
                        buildTitle(
                            Localization.of(context)
                                .getString('verificationCode'),
                            MediaQuery.of(context).size.height * 0.048),
                        _buildForm(),
                        _buildPhoneNumber(),
                        _buildButton(context),
                        _buildResendButton(),
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
          controller: _codeTextEditingController,
          autovalidate: _autoValidate,
          onChanged: (value) {
            smsCode = value;
          },
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter.digitsOnly,
          ],
          decoration: customInputDecoration(
              Localization.of(context).getString('typeCodeHere'),
              Icons.dialpad),
          validator: (value) {
            if (value.isEmpty) {
              return Localization.of(context)
                  .getString('verificationCodeValidation');
            }
            return null;
          },
        ),
      ),
    );
  }

  Padding _buildButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 40.0),
      child:
          customAccentButton(Localization.of(context).getString('login'), () {
        FocusScope.of(context).requestFocus(FocusNode());
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
        }, Localization.of(context).getString('termsAndConditions')),
      ),
    );
  }

  void _showDialog(String title, String message) {
    setState(() {
      _saving = false;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        title: title,
        description: message,
        buttonText: Localization.of(context).getString('ok'),
      ),
    );
  }

  Container _buildPhoneNumber() {
    return Container(
        margin: const EdgeInsets.only(top: 16.0, left: 24.0, right: 24.0),
        child: Text.rich(
          TextSpan(
            text: Localization.of(context)
                .getString("verificationCodeDescription"),
            style: TextStyle(color: ColorUtils.gray),
            children: <TextSpan>[
              TextSpan(
                  text: widget.phoneNumber,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
          textAlign: TextAlign.center,
        ));
  }

  GestureDetector _buildResendButton() {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 24.0, right: 24.0),
        child: Text(
          Localization.of(context).getString('resendCode'),
          style: TextStyle(
              color: ColorUtils.orangeAccent, fontWeight: FontWeight.bold),
        ),
      ),
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());

        setState(() {
          _saving = true;
        });

        if (_codeTimedOut) {
          widget.resendVerificationCode();
        } else {
          _showDialog(Localization.of(context).getString("error"),
              Localization.of(context).getString("cantRetry"));
        }
      },
    );
  }
}
