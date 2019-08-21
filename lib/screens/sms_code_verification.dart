import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SmsCodeVerification extends StatefulWidget {
  String smsCode;
  String verificationId;

  SmsCodeVerification(this.smsCode, this.verificationId);

  @override
  SmsCodeVerificationState createState() => SmsCodeVerificationState();
}

class SmsCodeVerificationState extends State<SmsCodeVerification> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Container(
              padding: EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Enter code"),
                  TextField(
                    decoration: InputDecoration(hintText: 'Code'),
                    onChanged: (value) {
                      widget.smsCode = value;
                    },
                  ),
                  SizedBox(height: 10.0),
                  RaisedButton(
                      onPressed: () {
                        FirebaseAuth.instance.currentUser().then((user) {
                          if (user != null) {
                            saveAccessToken(user.uid);
                            Navigator.of(context).pop();
                            Navigator.of(context)
                                .pushReplacementNamed('/homepage');
                          } else {
                            Navigator.of(context).pop();
                            signIn();
                          }
                        });
                      },
                      child: Text('Done'),
                      textColor: Colors.white,
                      elevation: 7.0,
                      color: Colors.blue)
                ],
              )),
        ),
      ),
    );
  }

  signIn() async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: widget.verificationId,
      smsCode: widget.smsCode,
    );
    FirebaseAuth _auth = FirebaseAuth.instance;

    final AuthResult user = await _auth.signInWithCredential(credential);
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.user.uid == currentUser.uid);

    if (user != null) {
      saveAccessToken(user.user.uid);
      Navigator.of(context).pushReplacementNamed('/homepage');
    }
  }

  Future saveAccessToken(String accessToken) async {
    await SharedPreferencesHelper.saveAccessToken(accessToken);
  }
}
