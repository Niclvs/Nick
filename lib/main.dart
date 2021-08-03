import 'dart:async';
import 'package:SpidrApp/helper/authenticate.dart';
import 'package:SpidrApp/helper/helperFunctions.dart';

import 'package:SpidrApp/views/introScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:SpidrApp/services/auth.dart';
import './views/pageViewsWrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterDownloader.initialize(debug: false);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool _seen =(prefs.getBool('seen') ?? false);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _seen ? MyApp() : Intro(),
      // routes: <String, WidgetBuilder>{
      //   '/intro': (BuildContext context) => new Intro(),
      // },
    ));
  });

}



class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{
  bool userIsLoggedIn;

  @override
  void initState() {
    super.initState();
    markSeen();
    getLoggedInState();
  }

  Future markSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('seen', true);
  }

  getLoggedInState() async {
    await HelperFunctions.getUserLoggedInSharedPreference().then((val) {
      setState(() {
        userIsLoggedIn = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AuthMethods>(
        create: (_) => AuthMethods(),
        child: MaterialApp(
          title: 'Spidr',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              scaffoldBackgroundColor: Color(0xff1F1F1F),
              primaryColor: Color(0xfffb934d),
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              canvasColor: Colors.transparent
          ),
          home: userIsLoggedIn != null ?
          userIsLoggedIn ?
          PageViewsWrapper() :
          Authenticate() :
          Container(
            child: Center(
              child: Authenticate(),
            ),
          ),
        )
    );
  }
}

