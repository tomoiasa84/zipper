import 'package:contractor_search/bloc/authentication_bloc.dart';
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

class SmsCodeVerification extends StatefulWidget {
  final String verificationId;
  final String name;
  final String location;
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
          saveAccessToken(token.token).then((token) {
            _authenticationBloc = AuthenticationBloc();
            _checkUser(user);
          });
        });
      } else {
        _showDialog(
            Localization.of(context).getString('error'),
            Localization.of(context).getString('loginErrorMessage'),
            Localization.of(context).getString('ok'));
      }
    } on PlatformException catch (e) {
      _showDialog(Localization.of(context).getString('error'), e.message,
          Localization.of(context).getString('ok'));
      setState(() {
        _saving = false;
      });
    }
  }

  void _checkUser(AuthResult authResult) {
    List<User> usersList = [];
    _authenticationBloc.getUsers().then((result) {
      if (result.data != null) {
        final List<Map<String, dynamic>> users =
            result.data['get_users'].cast<Map<String, dynamic>>();
        users.forEach((item) {
          usersList.add(User.fromJson(item));
        });
        User user = usersList.firstWhere(
            (user) => user.phoneNumber == widget.phoneNumber,
            orElse: () => null);
        if (widget.authType == AuthType.signUp) {
          if (user == null) {
            _signUp(authResult);
          } else if (!user.isActive) {
            _doUpdateUser(authResult);
          } else {
            SharedPreferencesHelper.clear().then((_) {
              _showDialog(
                  Localization.of(context).getString('error'),
                  Localization.of(context).getString('alreadySignedUp'),
                  Localization.of(context).getString('ok'));
              setState(() {
                _saving = false;
              });
            });
          }
        } else if (widget.authType == AuthType.login) {
          if (user == null) {
            SharedPreferencesHelper.clear().then((_) {
              _showDialog(
                  Localization.of(context).getString('error'),
                  Localization.of(context).getString('loginErrorMessage'),
                  Localization.of(context).getString('ok'));
            });
          } else {
            _finishLogin(authResult.user.uid);
          }
        }
      }
    });
  }

  void _signUp(AuthResult user) {
    List<LocationModel> locations = [];
    _authenticationBloc.getLocations().then((result) {
      setState(() {
        (result.data['get_locations']?.cast<Map<String, dynamic>>())?.forEach(
            (location) => locations.add(LocationModel.fromJson(location)));
        var loc = locations.firstWhere(
            (location) => location.city == widget.location,
            orElse: () => null);
        if (loc != null) {
          _createUser(user, loc.id);
        } else {
          _authenticationBloc.createLocation(widget.location).then((result) {
            if (result.data != null) {
              _createUser(user,
                  LocationModel.fromJson(result.data['create_location']).id);
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) => CustomDialog(
                  title: Localization.of(context).getString('error'),
                  description: result.errors[0].message,
                  buttonText: Localization.of(context).getString('ok'),
                ),
              );
            }
          });
        }
      });
    });
  }

  void _createUser(AuthResult user, int locationId) {
    _authenticationBloc
        .createUser(
            widget.name, locationId, user.user.uid, user.user.phoneNumber)
        .then((result) {
      setState(() {
        _saving = false;
      });
      if (result.data != null) {
        _finishLogin(user.user.uid);
      } else {
        SharedPreferencesHelper.clear().then((_) {
          _showDialog(
              Localization.of(context).getString('error'),
              result.errors[0].message,
              Localization.of(context).getString('ok'));
        });
      }
    });
  }

  void _doUpdateUser(AuthResult user) {
    List<LocationModel> locations = [];
    _authenticationBloc.getLocations().then((result) {
      setState(() {
        (result.data['get_locations']?.cast<Map<String, dynamic>>())?.forEach(
                (location) => locations.add(LocationModel.fromJson(location)));
        var loc = locations.firstWhere(
                (location) => location.city == widget.location,
            orElse: () => null);
        if (loc != null) {
          _updateUserData(user, loc.id);
        } else {
          _authenticationBloc.createLocation(widget.location).then((result) {
            if (result.data != null) {
              _updateUserData(user,
                  LocationModel.fromJson(result.data['create_location']).id);
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) => CustomDialog(
                  title: Localization.of(context).getString('error'),
                  description: result.errors[0].message,
                  buttonText: Localization.of(context).getString('ok'),
                ),
              );
            }
          });
        }
      });
    });
  }

  void _updateUserData(AuthResult user, int locationId){
    _authenticationBloc
        .updateUser(widget.name, locationId, user.user.uid,
        user.user.phoneNumber, true)
        .then((result) {
      setState(() {
        _saving = false;
      });
      if (result.data != null) {
        _finishLogin(user.user.uid);
      } else {
        SharedPreferencesHelper.clear().then((_) {
          _showDialog(
              Localization.of(context).getString('error'),
              result.errors[0].message,
              Localization.of(context).getString('ok'));
        });
      }
    });
  }

  void _finishLogin(String userId) {
    saveCurrentUserId(userId).then((userId) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => TutorialScreen()),
          ModalRoute.withName("/homepage"));
    });
  }

  Future saveAccessToken(String accessToken) async {
    await SharedPreferencesHelper.saveAccessToken(accessToken);
  }

  Future saveCurrentUserId(String userId) async {
    await SharedPreferencesHelper.saveCurrentUserId(userId);
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
                        buildLogo(context),
                        buildTitle(
                            Localization.of(context)
                                .getString('verificationCode'),
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
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child:
          customAccentButton(Localization.of(context).getString('login'), () {
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
