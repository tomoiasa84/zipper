import 'package:contractor_search/screens/sms_code_verification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  PhoneAuthScreenState createState() {
    return PhoneAuthScreenState();
  }
}

class PhoneAuthScreenState extends State<PhoneAuthScreen> {
  String phoneNo;
  String smsCode;
  String verificationId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
            padding: EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Enter phone number"),
                TextField(
                  decoration: InputDecoration(hintText: 'Phone number'),
                  onChanged: (value) {
                    this.phoneNo = value;
                  },
                ),
                SizedBox(height: 10.0),
                RaisedButton(
                    onPressed: verifyPhone,
                    child: Text('Continue'),
                    textColor: Colors.white,
                    elevation: 7.0,
                    color: Colors.blue)
              ],
            )),
      ),
    );
  }

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };
    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SmsCodeVerification(smsCode, verificationId)));
    };

    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential user) {
      print('verified');
    };

    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      print('${exception.message}');
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: this.phoneNo,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed);
  }
}
