import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:contractor_search/bloc/authentication_bloc.dart';
import 'package:contractor_search/layouts/terms_and_conditions_screen.dart';
import 'package:contractor_search/layouts/tutorial_screen.dart';
import 'package:contractor_search/model/location.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/auth_screen_type.dart';
import 'package:contractor_search/utils/auth_type.dart';
import 'package:contractor_search/utils/custom_dialog.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class AuthenticationScreen extends StatefulWidget {
  final bool showExpiredSessionMessage;

  const AuthenticationScreen({Key key, this.showExpiredSessionMessage})
      : super(key: key);

  @override
  AuthenticationScreenState createState() {
    return AuthenticationScreenState();
  }
}

class AuthenticationScreenState extends State<AuthenticationScreen> {
  //Text Field controller
  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _singUpPhoneNumberController =
      TextEditingController();
  final TextEditingController _loginPhoneNumberController =
      TextEditingController();
  final TextEditingController _signUpNameTextFieldController =
      TextEditingController();
  final TextEditingController _smsCodeVerificationController =
      TextEditingController();

  var authScreenType = AuthScreenType.SIGN_UP;
  var prevAuthScreenType = AuthScreenType.SIGN_UP;

  //Form Global Keys
  final _signUpFormKey = GlobalKey<FormState>();
  final _loginFormKey = GlobalKey<FormState>();
  final _smsVerificationFormKey = GlobalKey<FormState>();

  //Auto validate
  bool _signUpAutoValidate = false;
  bool _loginAutoValidate = false;
  bool _smsCodeAutoValidate = false;

  Duration _timeOut = const Duration(seconds: 30);
  List<LocationModel> locationsList = [];
  int authType = AuthType.signUp;
  AuthenticationBloc _authBloc = AuthenticationBloc();
  List<String> locations = [];
  bool _smsCodeSent = false;
  bool _codeTimedOut = false;
  String verificationId;
  bool _saving = false;
  String phoneNumber;
  Timer _codeTimer;
  String smsCode;

  bool connected = false;

  Future _getLocations() async {
    await _authBloc.getLocations().then((snapshot) {
      if (this.mounted) {
        setState(() {
          snapshot.forEach((location) {
            locations.add(location.city);
            locationsList.add(location);
          });
        });
      }
    });
  }

  @override
  void initState() {
    _getLocations();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (widget.showExpiredSessionMessage) {
        _showDialog(Localization.of(context).getString('yourSessionExpired'),
            Localization.of(context).getString('pleaseLoginAgain'));
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _typeAheadController.dispose();
    _signUpNameTextFieldController.dispose();
    _loginPhoneNumberController.dispose();
    _singUpPhoneNumberController.dispose();
    _smsCodeVerificationController.dispose();
    super.dispose();
  }

  Future<void> verifyPhone() async {
    _codeTimedOut = false;
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      _smsCodeSent = true;
      setState(() {
        _saving = false;
      });
      this.verificationId = verId;
      setState(() {
        prevAuthScreenType = authScreenType;
        _smsCodeVerificationController.clear();
        authScreenType = AuthScreenType.SMS_VERIFICATION;
      });
      _codeTimer = Timer(_timeOut, () {
        if (mounted) {
          setState(() {
            _codeTimedOut = true;
          });
        }
      });
    };

    final PhoneVerificationCompleted verifiedSuccess =
        (AuthCredential authCredential) {
      setState(() {
        _saving = false;
      });
      print('verified');
      _codeTimedOut = true;
      if (!_smsCodeSent && authCredential != null && connected) {
        authenticate(authCredential);
      }
    };

    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      print('${exception.message}');
      setState(() {
        _saving = false;
      });
      _showDialog(
          Localization.of(context).getString("error"), exception.message);
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: this.phoneNumber.split(" ").join(""),
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: _timeOut,
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed);
  }

  authenticate(AuthCredential credential) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      final AuthResult user = await _auth.signInWithCredential(credential);
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.user.uid == currentUser.uid);

      if (user != null) {
        user.user.getIdToken().then((token) {
          _authBloc.saveAccessToken(token.token).then((token) {
            _authenticate(user);
          });
        });
      } else {
        await _auth.signOut().then((_) {
          _showDialog(Localization.of(context).getString("error"),
              Localization.of(context).getString('loginErrorMessage'));
        });
      }
    } on PlatformException catch (e) {
      _showDialog(Localization.of(context).getString("error"), e.message);
    }
  }

  void _authenticate(AuthResult authResult) {
    _authBloc
        .getUserFromContact(authType == AuthType.signUp
            ? _singUpPhoneNumberController.text
            : _loginPhoneNumberController.text)
        .then((userFromContactResult) {
      User user = userFromContactResult.data != null &&
              userFromContactResult.data['get_userFromContact'] != null
          ? User.fromJson(userFromContactResult.data['get_userFromContact'])
          : null;

      if (authType == AuthType.signUp) {
        if (user == null) {
          _signUp(authResult);
        } else if (!user.isActive) {
          _updateUser(authResult, user);
        } else {
          FirebaseAuth.instance.signOut().then((_) {
            SharedPreferencesHelper.clear().then((_) {
              _showDialog(Localization.of(context).getString('error'),
                  Localization.of(context).getString('alreadySignedUp'));
            });
          });
        }
      } else if (authType == AuthType.login) {
        if (user == null) {
          FirebaseAuth.instance.signOut().then((_) {
            SharedPreferencesHelper.clear().then((_) {
              _showDialog(Localization.of(context).getString('error'),
                  Localization.of(context).getString('loginErrorMessage'));
            });
          });
        } else {
          _finishLogin(user.id, user.name);
        }
      }
    });
  }

  void _signUp(AuthResult user) {
    var loc = locationsList.firstWhere(
        (location) => location.city == _typeAheadController.text,
        orElse: () => null);
    if (loc != null) {
      _createUser(user, loc.id);
    } else {
      _authBloc.createLocation(_typeAheadController.text).then((result) {
        if (result.errors == null) {
          _createUser(
              user, LocationModel.fromJson(result.data['create_location']).id);
        } else {
          _showDialog(Localization.of(context).getString('error'),
              result.errors[0].message);
        }
      });
    }
  }

  void _createUser(AuthResult user, int locationId) {
    _authBloc
        .createUser(_signUpNameTextFieldController.text, locationId,
            user.user.uid, user.user.phoneNumber)
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

  void _updateUser(AuthResult authResult, User user) {
    var loc = locationsList.firstWhere(
        (location) => location.city == _typeAheadController.text,
        orElse: () => null);
    if (loc != null) {
      _updateUserData(authResult, loc.id, user);
    } else {
      _authBloc.createLocation(_typeAheadController.text).then((result) {
        if (result.errors == null) {
          _updateUserData(authResult,
              LocationModel.fromJson(result.data['create_location']).id, user);
        } else {
          _showDialog(Localization.of(context).getString('error'),
              result.errors[0].message);
        }
      });
    }
  }

  void _updateUserData(AuthResult authResult, int locationId, User user) {
    _authBloc
        .updateUser(
            user.id,
            authResult.user.uid,
            _signUpNameTextFieldController.text,
            locationId,
            true,
            authResult.user.phoneNumber)
        .then((result) {
      if (result.errors == null) {
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
    _authBloc.saveCurrentUserId(userId).then((userId) {
      _authBloc.saveCurrentUserName(userName).then((value) {
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

  void _showDialog(String title, String description) {
    setState(() {
      _saving = false;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        title: title,
        description: description,
        buttonText: Localization.of(context).getString("ok"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Connectivity().onConnectivityChanged,
        builder:
            (BuildContext context, AsyncSnapshot<ConnectivityResult> snapShot) {
          if (snapShot.hasData && snapShot.data != ConnectivityResult.none) {
            connected = snapShot.data != ConnectivityResult.none;
          }
          return WillPopScope(
            onWillPop: _onWillPop,
            child: SafeArea(
              top: false,
              bottom: false,
              child: ModalProgressHUD(
                inAsyncCall: _saving,
                child: Scaffold(
                  backgroundColor: ColorUtils.white,
                  body: _buildContent(),
                ),
              ),
            ),
          );
        });
  }

  Future<bool> _onWillPop() async {
    if (authScreenType == AuthScreenType.LOGIN) {
      setState(() {
        authScreenType = AuthScreenType.SIGN_UP;
      });
      return false;
    } else if (authScreenType == AuthScreenType.SMS_VERIFICATION) {
      setState(() {
        authScreenType = prevAuthScreenType;
      });
      return false;
    } else {
      return true;
    }
  }

  _buildContent() {
    switch (authScreenType) {
      case AuthScreenType.SIGN_UP:
        {
          this.phoneNumber = _singUpPhoneNumberController.text;
          return _buildSignUpScreen();
        }
      case AuthScreenType.LOGIN:
        {
          this.phoneNumber = _loginPhoneNumberController.text;
          return _buildLoginScreen();
        }
      case AuthScreenType.SMS_VERIFICATION:
        {
          return _buildSmsVerificationScreen();
        }
      default:
        return _buildSignUpScreen();
    }
  }

  Widget _buildSignUpScreen() {
    return Container(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 31.0),
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
                    Localization.of(context).getString('createAnAccount'), 0),
                _buildSignUpForm(),
                customAccentButton(
                    Localization.of(context).getString('continue'), () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  if (_signUpFormKey.currentState.validate()) {
                    if (connected) {
                      setState(() {
                        _saving = true;
                      });
                      authType = AuthType.signUp;
                      verifyPhone();
                    } else {
                      _showDialog(
                          "",
                          Localization.of(context)
                              .getString("noInternetConnection"));
                    }
                  } else {
                    setState(() {
                      _signUpAutoValidate = true;
                    });
                  }
                }),
                _buildBottomTexts()
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLoginScreen() {
    return Container(
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
                    setState(() {
                      prevAuthScreenType = authScreenType;
                      authScreenType = AuthScreenType.SIGN_UP;
                    });
                  }),
                  buildLogo(context),
                  buildTitle(Localization.of(context).getString('login'),
                      MediaQuery.of(context).size.height * 0.048),
                  _buildLoginForm(),
                  _buildLoginButton(),
                  _buildTermsAndConditions(context)
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSmsVerificationScreen() {
    return Container(
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
                    setState(() {
                      authScreenType = prevAuthScreenType;
                    });
                  }),
                  buildLogo(context),
                  buildTitle(
                      Localization.of(context).getString('verificationCode'),
                      MediaQuery.of(context).size.height * 0.048),
                  _buildSmsVerificationForm(),
                  _buildPhoneNumberText(),
                  _buildSmsButton(context),
                  _buildResendButton(),
                  _buildTermsAndConditions(context),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Form _buildSignUpForm() {
    return Form(
      key: _signUpFormKey,
      autovalidate: _signUpAutoValidate,
      child: Column(
        children: <Widget>[
          _buildNameTextField(),
          _buildLocationTextField(),
          _buildPhoneNumberTextField(),
        ],
      ),
    );
  }

  Container _buildNameTextField() {
    return Container(
      child: TextFormField(
        controller: _signUpNameTextFieldController,
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
      child: TypeAheadFormField(
        getImmediateSuggestions: true,
        textFieldConfiguration: TextFieldConfiguration(
            controller: this._typeAheadController,
            decoration: customInputDecoration(
                Localization.of(context).getString('location'),
                Icons.location_on)),
        suggestionsCallback: (pattern) async {
          if (locations.length == 0) {
            await _getLocations().then((value) {
              List<String> list = [];
              locations
                  .where((it) =>
                      it.toLowerCase().startsWith(pattern.toLowerCase()))
                  .toList()
                  .forEach((loc) => list.add(loc));
              return list;
            });
          }
          List<String> list = [];
          locations
              .where((it) => it.toLowerCase().startsWith(pattern.toLowerCase()))
              .toList()
              .forEach((loc) => list.add(loc));
          return list;
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(suggestion),
          );
        },
        transitionBuilder: (context, suggestionsBox, controller) {
          return suggestionsBox;
        },
        onSuggestionSelected: (suggestion) {
          this._typeAheadController.text = suggestion;
        },
        validator: (value) {
          if (value.isEmpty) {
            return Localization.of(context).getString('locationValidation');
          }
          return null;
        },
      ),
    );
  }

  Container _buildPhoneNumberTextField() {
    return Container(
      margin: const EdgeInsets.only(top: 35.0),
      child: TextFormField(
        controller: _singUpPhoneNumberController,
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
              setState(() {
                prevAuthScreenType = authScreenType;
                authScreenType = AuthScreenType.LOGIN;
              });
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

  Form _buildLoginForm() {
    return Form(
      autovalidate: _loginAutoValidate,
      key: _loginFormKey,
      child: Container(
        margin: const EdgeInsets.only(top: 35.0, left: 24.0, right: 24.0),
        child: TextFormField(
          controller: _loginPhoneNumberController,
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

  Expanded _buildTermsAndConditions(BuildContext context) {
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

  Padding _buildLoginButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child: customAccentButton(Localization.of(context).getString('continue'),
          () {
        FocusScope.of(context).requestFocus(FocusNode());
        if (_loginFormKey.currentState.validate()) {
          if (connected) {
            setState(() {
              _saving = true;
            });
            authType = AuthType.login;
            verifyPhone();
          } else {
            _showDialog(
                "", Localization.of(context).getString("noInternetConnection"));
          }
        } else {
          setState(() {
            _loginAutoValidate = true;
          });
        }
      }),
    );
  }

  Form _buildSmsVerificationForm() {
    return Form(
      key: _smsVerificationFormKey,
      child: Container(
        margin: const EdgeInsets.only(top: 35.0, left: 24.0, right: 24.0),
        child: TextFormField(
          onChanged: (value) {
            smsCode = value;
          },
          controller: _smsCodeVerificationController,
          autovalidate: _smsCodeAutoValidate,
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

  Padding _buildSmsButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 40.0),
      child:
          customAccentButton(Localization.of(context).getString('login'), () {
        FocusScope.of(context).requestFocus(FocusNode());
        if (_smsVerificationFormKey.currentState.validate()) {
          if (connected) {
            FirebaseAuth.instance.currentUser().then((user) {
              setState(() {
                _saving = true;
              });
              final AuthCredential credential = PhoneAuthProvider.getCredential(
                verificationId: verificationId,
                smsCode: smsCode,
              );
              authenticate(credential);
            });
          } else {
            _showDialog(
                "", Localization.of(context).getString("noInternetConnection"));
          }
        } else {
          setState(() {
            _smsCodeAutoValidate = true;
          });
        }
      }),
    );
  }

  Container _buildPhoneNumberText() {
    return Container(
        margin: const EdgeInsets.only(top: 16.0, left: 24.0, right: 24.0),
        child: Text.rich(
          TextSpan(
            text: Localization.of(context)
                .getString("verificationCodeDescription"),
            style: TextStyle(color: ColorUtils.gray),
            children: <TextSpan>[
              TextSpan(
                  text: phoneNumber,
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
        _smsCodeVerificationController.clear();
        FocusScope.of(context).requestFocus(FocusNode());
        setState(() {
          _saving = true;
        });

        if (_codeTimedOut) {
          Fluttertoast.showToast(
              msg: Localization.of(context).getString("resendSmsCodeMessage"),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 1,
              backgroundColor: ColorUtils.lightLightGray,
              textColor: ColorUtils.textBlack,
              fontSize: 16.0);
          verifyPhone();
        } else {
          _showDialog(Localization.of(context).getString("error"),
              Localization.of(context).getString("cantRetry"));
        }
      },
    );
  }
}
