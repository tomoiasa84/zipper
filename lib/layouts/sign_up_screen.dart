import 'package:contractor_search/bloc/sign_up_bloc.dart';
import 'package:contractor_search/layouts/login_screen.dart';
import 'package:contractor_search/layouts/sms_code_verification_screen.dart';
import 'package:contractor_search/layouts/terms_and_conditions_screen.dart';
import 'package:contractor_search/layouts/tutorial_screen.dart';
import 'package:contractor_search/model/location.dart';
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
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SignUpScreen extends StatefulWidget {
  @override
  SignUpScreenState createState() {
    return SignUpScreenState();
  }
}

class SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String phoneNumber;
  String name;
  String verificationId;
  bool _autoValidate = false;
  bool _saving = false;
  final TextEditingController _typeAheadController = TextEditingController();
  List<String> locations = [];
  SignUpBloc _signUpBloc;
  Duration _timeOut = const Duration(minutes: 1);

  List<LocationModel> locationsList = [];

  bool _smsCodeSent = false;

  Future<void> verifyPhone(int authType) async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      _smsCodeSent = true;
      setState(() {
        _saving = false;
      });
      this.verificationId = verId;
      goToSmsVerificationPage(authType);
    };

    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential authCredential) {
      setState(() {
        _saving = false;
      });
      print('verified');
      if(!_smsCodeSent && authCredential!=null) {
        signIn(authCredential);
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

  signIn(AuthCredential credential) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      final AuthResult user = await _auth.signInWithCredential(credential);
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.user.uid == currentUser.uid);

      if (user != null) {
        user.user.getIdToken().then((token) {
          _signUpBloc.saveAccessToken(token.token).then((token) {
            _checkUser(user);
          });
        });
      } else {
        _showDialog(Localization.of(context).getString("error"),Localization.of(context).getString('loginErrorMessage'));
      }
    } on PlatformException catch (e) {
     _showDialog(Localization.of(context).getString("error"),e.message);
    }
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

  void _checkUser(AuthResult authResult) {
    List<User> usersList = [];
    _signUpBloc.getUsers().then((result) {
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
          _signUp(authResult);
        } else if (!user.isActive) {
          _updateUser(authResult);
        } else {
          SharedPreferencesHelper.clear().then((_) {
            _showDialog("", Localization.of(context).getString('alreadySignedUp'));
          });
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
      _signUpBloc.createLocation(_typeAheadController.text).then((result) {
        if (result.data != null) {
          _createUser(
              user, LocationModel.fromJson(result.data['create_location']).id);
        } else {
          _showDialog(Localization.of(context).getString('error'), result.errors[0].message);
        }
      });
    }
  }

  void _createUser(AuthResult user, int locationId) {
    _signUpBloc
        .createUser(name, locationId, user.user.uid, user.user.phoneNumber)
        .then((result) {
      setState(() {
        _saving = false;
      });
      if (result.data != null) {
        User user = User.fromJson(result.data['create_user']);
        _finishLogin(user.id, user.name);
      } else {
        SharedPreferencesHelper.clear().then((_) {
          _showDialog(Localization.of(context).getString('error'), result.errors[0].message);
        });
      }
    });
  }

  void _updateUser(AuthResult user) {
    var loc = locationsList.firstWhere(
            (location) => location.city == _typeAheadController.text,
        orElse: () => null);
      setState(() {
        if (loc != null) {
          _updateUserData(user, loc.id);
        } else {
          _signUpBloc.createLocation(_typeAheadController.text).then((result) {
            if (result.data != null) {
              _updateUserData(user,
                  LocationModel.fromJson(result.data['create_location']).id);
            } else {
              _showDialog(Localization.of(context).getString('error'), result.errors[0].message);
            }
          });
        }
      });
  }

  void _updateUserData(AuthResult user, int locationId) {
    _signUpBloc
        .updateUser(
            name, locationId, user.user.uid, user.user.phoneNumber, true)
        .then((result) {
      if (result.data != null) {
        User user = User.fromJson(result.data['update_user']);
        _finishLogin(user.id, user.name);
      } else {
        SharedPreferencesHelper.clear().then((_) {
          _showDialog(Localization.of(context).getString('error'), result.errors[0].message);
        });
      }
    });
  }

  void _finishLogin(String userId, String userName) {
    _signUpBloc.saveCurrentUserId(userId).then((userId) {
      _signUpBloc.saveCurrentUserName(userName).then((value) {
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

  void goToSmsVerificationPage(int authType) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SmsCodeVerificationScreen(verificationId,
                name, _typeAheadController.text, phoneNumber, authType)));
  }

  @override
  void initState() {
    _signUpBloc = SignUpBloc();
    _signUpBloc.getLocations().then((snapshot) {
      if (this.mounted) {
        setState(() {
          snapshot.forEach((location) {
            locations.add(location.city);
            locationsList.add(location);
          });
        });
      }
    });
    super.initState();
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
                        FocusScope.of(context).requestFocus(FocusNode());
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
      child: TypeAheadFormField(
        getImmediateSuggestions: true,
        textFieldConfiguration: TextFieldConfiguration(
            controller: this._typeAheadController,
            decoration: customInputDecoration(
                Localization.of(context).getString('location'),
                Icons.location_on)),
        suggestionsCallback: (pattern) {
          List<String> list = [];
          locations
              .where((it) => it.startsWith(pattern))
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
