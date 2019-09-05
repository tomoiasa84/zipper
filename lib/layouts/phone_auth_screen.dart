import 'package:contractor_search/bloc/authentication_bloc.dart';
import 'package:contractor_search/layouts/login_screen.dart';
import 'package:contractor_search/layouts/sms_code_verification.dart';
import 'package:contractor_search/layouts/terms_and_conditions_screen.dart';
import 'package:contractor_search/model/location.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/auth_type.dart';
import 'package:contractor_search/utils/custom_dialog.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:contractor_search/utils/helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  PhoneAuthScreenState createState() {
    return PhoneAuthScreenState();
  }
}

class PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();

  String phoneNumber;
  String name;
  String location;
  String verificationId;
  bool _autoValidate = false;
  bool _saving = false;
  List<LocationModel> locations = [];
  AuthenticationBloc _authenticateBloc;

  Future<void> verifyPhone(int authType) async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      setState(() {
        _saving = false;
      });
      this.verificationId = verId;
      var loc = locations.firstWhere(
          (location) => location.city == _typeAheadController.text,
          orElse: () => null);
      if (loc != null) {
        goToSmsVerificationPage(loc, authType);
      } else {
        _authenticateBloc.createLocation(this.location).then((result) {
          if (result.data != null) {
            goToSmsVerificationPage(
                LocationModel.fromJson(result.data['create_location']),
                authType);
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

  void goToSmsVerificationPage(LocationModel location, int authType) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SmsCodeVerification(
                verificationId, name, location.id, phoneNumber, authType)));
  }

  void checkPhoneNumber() {
    setState(() {
      _saving = true;
    });
    List<User> usersList = [];
    _authenticateBloc.getUsers().then((result) {
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
          verifyPhone(AuthType.signUp);
        } else if (!user.isActive) {
          verifyPhone(AuthType.update);
        } else {
          _showDialog(
              Localization.of(context).getString('error'),
              Localization.of(context).getString('alreadySignedUp'),
              Localization.of(context).getString('ok'));
          setState(() {
            _saving = false;
          });
        }
      }
    });
  }

  @override
  void initState() {
    _authenticateBloc = AuthenticationBloc();
    _authenticateBloc.getLocations().then((result) {
      if (this.mounted) {
        if (result.data != null) {
          setState(() {
            (result.data['get_locations']?.cast<Map<String, dynamic>>())
                ?.forEach((location) =>
                    locations.add(LocationModel.fromJson(location)));
          });
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
                        if (_formKey.currentState.validate()) {
                          checkPhoneNumber();
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
        textFieldConfiguration: TextFieldConfiguration(
            onChanged: (value) {
              this.location = value;
            },
            controller: this._typeAheadController,
            decoration: customInputDecoration(
                Localization.of(context).getString('location'),
                Icons.location_on)),
        suggestionsCallback: (pattern) {
          List<String> list = [];
          locations
              .where((it) => it.city.startsWith(pattern))
              .toList()
              .forEach((loc) => list.add(loc.city));
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
        onSaved: (value) => this.location = value,
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
