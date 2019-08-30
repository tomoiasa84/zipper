import 'package:contractor_search/bloc/login_bloc.dart';
import 'package:contractor_search/layouts/home_page.dart';
import 'package:contractor_search/layouts/terms_and_conditions_screen.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/string_utils.dart';
import 'package:contractor_search/utils/custom_dialog.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:contractor_search/utils/helper.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  var _autoValidate = false;
  LoginBloc _loginBloc;
  String phoneNumber;

  @override
  void didChangeDependencies() {
    _loginBloc = LoginBloc();
    super.didChangeDependencies();
  }

  void _login() {
    List<User> usersList = [];
    _loginBloc.getUsers().then((result) {
      if (result.data != null) {
        final List<Map<String, dynamic>> users =
            result.data['get_users'].cast<Map<String, dynamic>>();
        users.forEach((item) {
          usersList.add(User.fromJson(item));
        });
        User user = usersList.firstWhere(
            (user) => user.phoneNumber == this.phoneNumber,
            orElse: () => null);
        if (user != null) {
          saveAccessToken(user.id).then((id) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
                ModalRoute.withName("/homepage"));
          });
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) => CustomDialog(
              title: Strings.error,
              description: Strings.loginErrorMessage,
              buttonText: Strings.ok,
            ),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
            title: Strings.error,
            description: Strings.loginErrorMessage,
            buttonText: Strings.ok,
          ),
        );
      }
    });
  }

  Future saveAccessToken(String accessToken) async {
    await SharedPreferencesHelper.saveAccessToken(accessToken);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
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
                      buildTitle(Strings.login,
                          MediaQuery.of(context).size.height * 0.048),
                      _buildForm(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 40.0),
                        child: customAccentButton(Strings.continueText, () {
                          if (_formKey.currentState.validate()) {
                            _login();
                          } else {
                            setState(() {
                              _autoValidate = true;
                            });
                          }
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
            left: 10.0, top: 35.0, right: 10.0, bottom: 10.0),
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
}
