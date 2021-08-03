
import 'package:SpidrApp/helper/helperFunctions.dart';
import 'package:SpidrApp/services/auth.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:flutter/material.dart';
import './pageViewsWrapper.dart';
import 'package:SpidrApp/helper/functions.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUp extends StatefulWidget {
  final Function toggle;
  SignUp(this.toggle);
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  bool isLoading = false;
  bool _checkbox = false;

  AuthMethods authMethods = new AuthMethods();

  final formKey = GlobalKey<FormState>();

  TextEditingController userNameTextEditingController = new TextEditingController();
  TextEditingController emailTextEditingController = new TextEditingController();
  TextEditingController passwordTextEditingController = new TextEditingController();

  signMeUp(){
    if(formKey.currentState.validate()){

      Map<String, dynamic> userInfoMap = authMethods.genUserInfo(userNameTextEditingController.text, emailTextEditingController.text);

      HelperFunctions.saveUserEmailSharedPreference(emailTextEditingController.text);
      HelperFunctions.saveUserNameSharedPreference(userNameTextEditingController.text);

      setState(() {
        isLoading = true;
      });
      authMethods.signUpWithEmailAndPassword(
          emailTextEditingController.text,
          passwordTextEditingController.text
      ).then((val){
        DatabaseMethods(uid: val.uid).uploadUserInfo(userInfoMap);
        HelperFunctions.saveUserLoggedInSharedPreference(true);
        authMethods.verifyEmail();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PageViewsWrapper()
            )
        );
      });
    }
  }

  void _launchURL(url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: isLoading ? sectionLoadingIndicator() :
        GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.bottomCenter,
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Container(
                    margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/20),
                    child: Image.asset(
                      'assets/images/login_logo.png',
                      width: MediaQuery.of(context).size.width/2.5,
                      height: MediaQuery.of(context).size.width/2.5,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          validator: (val){
                            return val.length > 18 ? "Max length 18" :
                            emptyStrChecker(val) ?
                            "Sorry, Spidr ID can not be empty" : null;
                          },
                          controller: userNameTextEditingController,
                          style: TextStyle(color: Colors.black),
                          cursorColor: Colors.orangeAccent,
                          decoration: InputDecoration(
                            hintText: "Enter a Username",
                            labelText: "Spidr ID",
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
                        TextFormField(
                          validator: (val){
                            return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val) ? null : "Please provide a valid email";
                          },
                          controller: emailTextEditingController,
                          style: TextStyle(color: Colors.black),
                          cursorColor: Colors.orangeAccent,
                          decoration: InputDecoration(
                            hintText: "Enter an email",
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
                        TextFormField(
                          obscureText: true,
                          validator: (val){
                            return val.length > 6 ? null : "Password is not valid";
                          },
                          controller: passwordTextEditingController,
                          style: TextStyle(color: Colors.black),
                          cursorColor: Colors.orangeAccent,
                          decoration: InputDecoration(
                            hintText: "Enter a Password",
                            labelText: "Password",
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
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 27),
                    child: Row(
                      children: [
                        SizedBox(
                          height:18,
                          width:18,
                          child: Checkbox(
                            value: _checkbox,
                            onChanged: (value) {
                              setState(() {
                                _checkbox = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(width:5),
                        Flexible(
                          child: GestureDetector(
                            onTap: (){
                              _launchURL('https://www.iubenda.com/terms-and-conditions/80156886');
                            },
                            child: Text(_checkbox ? "You have agreed to our EULA Agreement" : "Review our EULA Agreement",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold
                            ),),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      _checkbox ? signMeUp() : null;
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 18),
                      decoration: _checkbox ? BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFF9800),
                                const Color(0xFFEA80FC)
                              ]
                          ),
                          borderRadius: BorderRadius.circular(30)
                      ) : BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(30)
                      ),
                      child: Text("Join", style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                      ),),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account?", style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14
                      ),),
                      GestureDetector(
                        onTap: (){
                          widget.toggle();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 25),
                          child: Text(" Hop on now", style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                          ),),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }
}
