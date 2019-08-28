import 'package:contractor_search/layouts/terms_and_conditions_screen.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/string_utils.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

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
                        child: customAccentButton(Strings.continueText, () {}),
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
      key: _formKey,
      child: Container(
        margin: const EdgeInsets.only(top: 35.0, left: 24.0, right: 24.0),
        child: TextFormField(
          onChanged: (value) {},
          keyboardType: TextInputType.phone,
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter.digitsOnly,
          ],
          decoration: customInputDecoration(Strings.phoneNumber, Icons.phone),
          validator: (value) {
            if (value.isEmpty) {
              return Strings.phoneNumberValidation;
            }
            return null;
          },
        ),
      ),
    );
  }
}
