import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/helper/functions.dart';
import 'package:SpidrApp/helper/helperFunctions.dart';
import 'package:SpidrApp/services/database.dart';

import 'package:SpidrApp/widgets/dialogWidgets.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:SpidrApp/views/streamScreen.dart';
import 'package:SpidrApp/views/circleMediaScreen.dart';
import 'package:SpidrApp/views/chatsScreen.dart';


class PageViewsWrapper extends StatefulWidget {
  @override
  _PageViewsWrapperState createState() => _PageViewsWrapperState();
}

class _PageViewsWrapperState extends State<PageViewsWrapper> {

  int _selectedIndex = 0;
  final PageController pageController = PageController(initialPage:0, keepPage: false,);
  final spidrIdKey= GlobalKey <FormState>();
  TextEditingController spidrIdTextEditingController = new TextEditingController();
  bool ready = false;

  setUserInfo() async{
    User _user = FirebaseAuth.instance.currentUser;
    Constants.myName = await HelperFunctions.getUserNameInSharedPreference();
    Constants.myUserId = _user.uid;
    DocumentReference userDocRef = DatabaseMethods().userCollection.doc(Constants.myUserId);
    DocumentSnapshot userSnapshot = await userDocRef.get();

    bool getStarted = userSnapshot.data()["getStarted"] != null && userSnapshot.data()["getStarted"];

    if(getStarted) await showGetStartedDialog(context);

    if(Constants.myName == null || Constants.myName == "null null"){
        String name = userSnapshot.data()['name'];
        if(name == null || name == "null null"){
          if(name == "null null") spidrIdTextEditingController.text = name;
          await showSpidrIdBoxDialog(context, userDocRef, spidrIdKey, spidrIdTextEditingController);
        }else{
          Constants.myName = name;
        }
      }

      Constants.myProfileImg = userSnapshot.data()['profileImg'];
      Constants.myAnonImg = userSnapshot.data()['anonImg'];
      Constants.myEmail = _user.email;
      Constants.myQuote = userSnapshot.data()['quote'];
      Constants.myBlockList = userSnapshot.data()['blockList'] != null ? userSnapshot.data()['blockList'] : [];
      // Constants.myRemovedMedia = userSnapshot.data()['removedMedia'] != null ? userSnapshot.data()['removedMedia'] : [];

      ready = true;
      setState(() {});
      registerNotification(context, Constants.myUserId);

  }

  @override
  void initState() {
    // TODO: implement initState
    // DatabaseMethods().cleanUpDeletedGroups();
    setUserInfo();
    super.initState();
  }

  void bottomTapped(int index){
    setState((){
      _selectedIndex = index;
    });
    pageController.jumpToPage(_selectedIndex);
  }

  void pageChanged(int index){
    setState((){
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
        body: ready ?
        PageView(
          controller: pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            ChatsScreen(),
            StreamScreen(),
            CircleMediaScreen(),
          ],
          onPageChanged: pageChanged,
        ) : sectionLoadingIndicator(),

        bottomNavigationBar: BottomAppBar(
            color: Colors.black,
            elevation: 0.0,
            child:Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                bottomAppBarItem(_selectedIndex == 0 ? navBarIconsFilled[0][1] : navBarIconsFilled[0][0], 0),
                bottomAppBarItem(_selectedIndex == 1 ? navBarIconsFilled[1][1] : navBarIconsFilled[1][0], 1),
                bottomAppBarItem(_selectedIndex == 2 ? navBarIconsFilled[2][1] : navBarIconsFilled[2][0], 2),
              ],
            )
        )
    );
  }

  Widget bottomAppBarItem(String iconPath, int index){
    return GestureDetector(
      onTap: (){
        bottomTapped(index);
      },
      child:Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 40.5,
            width: 40.5,
            child: Image.asset(iconPath, fit:BoxFit.contain),
          ),
          // _selectedIndex == index ?
          // Icon(Icons.circle, size: 4.5,color: Colors.orange, ) :
          // SizedBox.shrink()
        ],
      ),
    );
  }
}