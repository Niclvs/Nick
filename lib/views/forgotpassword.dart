import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordScreen extends StatelessWidget {

  final TextEditingController editController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text ("Forgot Password?", style:TextStyle(color:Colors.black, fontWeight: FontWeight.bold),
          ),
          elevation: 0
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 36),
          height: MediaQuery.of(context).size.height*0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/forgotpassword.png',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width/2,
                fit: BoxFit.cover,
              ),
              Container(
                padding: EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Enter the email address associated with your account.',
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                  SizedBox(height: 20,),
                  TextField(
                    controller: editController,
                    decoration: InputDecoration(
                      hintText: "Enter your Email",
                      labelText: "Email",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                    ),
                  ),
                    SizedBox(height: 40.0),
                    Container(
                      height: 40.0,
                      child: Material(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.orange,
                        elevation: 0.0,
                        child: InkWell(
                            onTap: () {
                              resetPassword(context);
                            },
                            child: Center(
                                child: Text(
                                  'RESET PASSWORD',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, color: Colors.white
                                  ),
                                )
                            )
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void resetPassword(BuildContext context) async {
    /*
    if (editController.text.length < 5 || !editController.text.contains("@")) {
      Fluttertoast.showToast(msg: "Enter valid email");
      return;
    }
    */

    await FirebaseAuth.instance.sendPasswordResetEmail(email: editController.text).then((value) {
      Fluttertoast.showToast(msg: "Reset password link has been sent. Please check your email to change the password.");
      Navigator.pop(context);
    }).catchError((onError) {
      if (onError.toString().contains("The email template corresponding to this action contains an invalid sender email or name.")) {
        Fluttertoast.showToast(msg: "Email not found");
      } else if (onError.toString().contains("The email address is badly formatted.")){
        //print(onError.toString());
        Fluttertoast.showToast(msg: "Email badly formatted");
      }else{
        Fluttertoast.showToast(msg: "Unknown error");
      }
    });


  }
}
