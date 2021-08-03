import 'package:SpidrApp/helper/functions.dart';
import 'package:SpidrApp/views/signin.dart';
import 'package:SpidrApp/views/signup.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  Authenticate();
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  bool showSignIn = true;

  void toggleView(){
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(showSignIn){
      return SignIn(toggleView);
    }else{
      return SignUp(toggleView);
    }
  }
}
