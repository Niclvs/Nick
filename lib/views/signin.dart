import 'dart:math';
import 'package:SpidrApp/helper/helperFunctions.dart';
import 'package:SpidrApp/services/auth.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:apple_sign_in/apple_sign_in_button.dart';
import 'package:apple_sign_in/scope.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'forgotpassword.dart';
import 'package:SpidrApp/helper/functions.dart';
import 'package:SpidrApp/views/pageViewsWrapper.dart';


class SignIn extends StatefulWidget {
  final Function toggle;
  SignIn(this.toggle);
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final formKey = GlobalKey<FormState>();

  final flatButtonStyle = TextButton.styleFrom(
    padding: EdgeInsets.symmetric(vertical: 8),
  );

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController emailTextEditingController = new TextEditingController();
  TextEditingController passwordTextEditingController = new TextEditingController();
  bool isLoading = false;
  bool invalidPassword = false;
  bool invalidEmail = false;
  bool hidePass = true;

  QuerySnapshot snapshotUserInfo;


  Future<void> _signInWithApple(BuildContext context) async {
    try {
        final authService = Provider.of<AuthMethods>(context, listen: false);

        final user = await authService.signInWithApple(
            scopes: [Scope.email, Scope.fullName]
        );

        // final firebaseUser = user;
        Map<String, dynamic> userInfoMap = authMethods.genUserInfo(user.displayName, user.email);

        authMethods.appleSignIn(user).then((val) async{

          DocumentSnapshot userSnapshot = await DatabaseMethods(uid: val.uid).getUserById();

          if(!userSnapshot.exists){
            await DatabaseMethods(uid: val.uid).uploadUserInfo(userInfoMap);
          }

          HelperFunctions.saveUserLoggedInSharedPreference(true);
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => PageViewsWrapper()
          ));
        });

    }catch (e) {
      print(e);
    }
    }

  googleSignIn() async {
    try {
      //TODO understand errors and adjust error messages - franky
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn().catchError((onError) {
        // print("1");
        // print(onError);
        // print(onError.toString());
        Fluttertoast.showToast(msg: "Google account error. Please try signing in without google.");
      });

      GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication.catchError((onError) {
        // print("2");
        // print(onError.toString());
        Fluttertoast.showToast(msg: "Google account error. Please try signing in without google.");
      });

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential result = await _auth.signInWithCredential(credential).catchError((onError) {
        // print("3");
        // print(onError.toString());
        Fluttertoast.showToast(msg: "Google account error. Please try signing in without google.");
      });
      User firebaseUser = result.user;

      Map<String, dynamic> userInfoMap = authMethods.genUserInfo(firebaseUser.displayName, firebaseUser.email);


      authMethods.googleSignIn(firebaseUser).then((val) async{

        DocumentSnapshot userSnapshot = await DatabaseMethods(uid: val.uid).getUserById();
        if(!userSnapshot.exists){
          await DatabaseMethods(uid: val.uid).uploadUserInfo(userInfoMap);
        }
        HelperFunctions.saveUserLoggedInSharedPreference(true);
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => PageViewsWrapper()
        ));
      });

    }catch (e) {
      print(e);
    }
  }

 signIn() async {
    if(formKey.currentState.validate()){
      setState(() {
        isLoading = true;
      });

      try{
        await authMethods.signInWithEmailAndPassword(emailTextEditingController.text, passwordTextEditingController.text)
            .then((result) async {

          if(result != null) {
            QuerySnapshot userInfoSnapshot =
            await databaseMethods.getUserByUserEmail(emailTextEditingController.text);

            HelperFunctions.saveUserLoggedInSharedPreference(true);
            HelperFunctions.saveUserNameSharedPreference(
                userInfoSnapshot.docs[0].data()["name"]
            );
            HelperFunctions.saveUserEmailSharedPreference(
                userInfoSnapshot.docs[0].data()["Email"]
            );

            Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => PageViewsWrapper()));
          } else {
            setState(() {
              isLoading = false;
            });
          }
        });
      } catch (e){
        if(e == "[firebase_auth/wrong-password] The password is invalid or the user does not have a password."){
          setState(() {
            invalidPassword = true;
          });
        }else if(e == "[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted."){
          setState(() {
            invalidEmail = true;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TargetPlatform platform = Theme.of(context).platform;

    return Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration:  BoxDecoration(
                gradient:  LinearGradient(
                  colors: [
                    const Color(0xFF9c27B0),
                    const Color(0xFFF57f17),
                  ],
                ),
              ),
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: new Image.asset(
                        'assets/images/head.png',
                        width: MediaQuery.of(context).size.width/1.9,
                        height: MediaQuery.of(context).size.width/1.9,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                        TextFormField(
                          validator: (val){
                            return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val) ?
                            null : "Invalid Email";
                          },
                          controller: emailTextEditingController,

                          style: TextStyle(color: Colors.white),
                          cursorColor: Colors.orange,
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.mail_rounded,
                                color: Colors.white
                            ),
                            hintText: "Enter your email",
                            hintStyle: TextStyle(color: Colors.white),
                            labelText: "Email",
                            labelStyle: TextStyle(color: Colors.white),
                            errorText: invalidEmail ? "Email is not registered :(": null,
                            errorStyle: TextStyle(color:Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.orangeAccent),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.orangeAccent),
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.orangeAccent),
                            ),
                          ),
                        ),
                        TextFormField(
                          obscureText: hidePass,
                          validator: (val){
                            return val.length > 6 ? null : "Invalid password";
                          },
                          controller: passwordTextEditingController,
                          style: TextStyle(color: Colors.white,),
                          cursorColor: Colors.orange,

                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.lock,
                                color: Colors.white
                            ),
                            suffixIcon: GestureDetector(
                              onTap: (){
                                setState(() {
                                  hidePass = !hidePass;
                                });
                              },
                              child: Icon(
                                Icons.visibility,
                                  color: Colors.white
                              ),
                            ),
                            hintText: "Enter your Password",
                            hintStyle: TextStyle(color: Colors.white),
                            labelText: "Password",
                            labelStyle: TextStyle(color: Colors.orangeAccent),
                            errorText: invalidPassword ? "Password incorrect :(": null,
                            errorStyle: TextStyle(color: Colors.white) ,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.orangeAccent),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.orangeAccent),
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.orangeAccent),
                            ),
                          ),
                        ),
                      ],),
                    ),
                    // SizedBox(height:20,),
                    GestureDetector(
                      onTap: (){
                        signIn();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        margin: EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFEC407A),
                                  const Color(0xFFEC407A)
                                ]
                            ),
                            borderRadius: BorderRadius.circular(30)
                        ),
                        child: Text("Hop On", style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),),
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        alignment: Alignment.center,
                        child: TextButton(
                            style: flatButtonStyle,
                            child: Text(
                              "Forgot your Password?",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline
                              )
                            ),
                            onPressed:(){
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordScreen()));
                            }
                        ),
                      ),
                    ),
                  new Wrap(
                      // spacing: 1.0, // gap between adjacent chips
                      // runSpacing: 1.0, // gap between lines
                      children: <Widget>[
                        GestureDetector(
                          onTap: (){
                            googleSignIn();
                          },
                          child: Center(
                            child: new Image.asset(
                              'assets/images/GoogleSignIn.png',
                              width: MediaQuery.of(context).size.width/4.5,
                            ),
                          ),
                        ),
                        if (platform == TargetPlatform.iOS)
                          AppleSignInButton(
                            type: ButtonType.continueButton,
                            onPressed: (){
                              _signInWithApple(context);
                            },
                          ),
                      ]
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: (){
                            widget.toggle();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Text("Don't have an account? Join now", style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }

}
