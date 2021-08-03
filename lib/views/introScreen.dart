import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:SpidrApp/main.dart';

class Intro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );

    return MaterialApp(
      title: 'Introduction screen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: OnBoardingPage(),
    );
  }
}

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MyApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TargetPlatform platform = Theme.of(context).platform;
    const bodyStyle = TextStyle(fontSize: 18.0, color: Colors.black);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 27.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "Welcome to the Spidr Community",
          body: "The easiest way to become a part of groups, skip all the unnecessary steps and just search and join groupchats",
          image: Center(child: Image.asset("assets/icon/1.PNG",
            width: MediaQuery.of(context).size.width/1.4,
            height: MediaQuery.of(context).size.width/1.4,
          )),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Snippets",
          body: "Take a Snippet, add a hashtag and every group chat with that tag in their profile gets to see ¥our creation. ",
          image: Center(child: Image.asset("assets/icon/ET.png",
            width: MediaQuery.of(context).size.width/1.4,
            height: MediaQuery.of(context).size.width/1.4,
          )),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Backpack",
          body: "Grab the good stuff from different group chats and store them in your Spidr backpack",
          image: Center(child: Image.asset("assets/icon/#.png",
            width: MediaQuery.of(context).size.width/1.4,
            height: MediaQuery.of(context).size.width/1.4,
          )),
          decoration: pageDecoration,
        ),

        PageViewModel(
          title: "Show off your friend groups with group pages",
          bodyWidget: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                children: [
                  TextSpan(
                      text: "Tap on the group avatar to view your group profile ",
                      style: bodyStyle
                  ),
                  WidgetSpan(
                    child: Icon(Icons.donut_large_rounded),
                  )
                ]
            ),
          ),

          image: Center(child: Image.asset("assets/icon/Untitled design (20).png",
            width: MediaQuery.of(context).size.width/1.4,
            height: MediaQuery.of(context).size.width/1.4,
          )),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Hop on and Start Connecting",
          body: "Add hash tags to your profile to receive special snippets and get suggested groupchats",
          image: Center(child: Image.asset("assets/icon/Yeezy.png",
            width: MediaQuery.of(context).size.width/1.4,
            height: MediaQuery.of(context).size.width/1.4,)),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Skip',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange) ),
      next: Icon(platform == TargetPlatform.android ? Icons.arrow_forward : CupertinoIcons.arrow_right, color: Colors.black,),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
      dotsDecorator: const DotsDecorator(
        size: Size(5.0, 5.0),
        color: Colors.grey,
        activeColor: Colors.orange,
        activeSize: Size(15.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}