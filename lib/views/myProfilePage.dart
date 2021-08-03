import 'dart:io';
import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/services/fileUpload.dart';
import 'package:SpidrApp/views/backpackScreen.dart';
import 'package:SpidrApp/views/viewBanner.dart';
import 'package:SpidrApp/views/settingsScreen.dart';


import 'package:SpidrApp/widgets/dialogWidgets.dart';
import 'package:SpidrApp/widgets/groupsListDisplay.dart';
import 'package:SpidrApp/widgets/profilePageWidgets.dart';
import 'package:SpidrApp/widgets/storiesListDisplay.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:SpidrApp/views/aboutSpidr.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:SpidrApp/widgets/bottomSheetWidgets.dart';

class MyProfileScreen extends StatefulWidget {
  MyProfileScreen();

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  Stream itemsStream;
  Stream storyStream;

  TextEditingController quoteController = TextEditingController(text: Constants.myQuote);
  TextEditingController tagController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool uploading = false;
  File pickedImage;

  editAboutMe(String newQuote) {
    if (formKey.currentState.validate()) {
      DatabaseMethods(uid: Constants.myUserId).editUserQuote(newQuote);
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  deleteMyTag(String tag) {
    DatabaseMethods(uid: Constants.myUserId).deleteUserTag(tag);
  }

  addOrEditMyTag(String newTag, int index) {
    if (formKey.currentState.validate()) {
      DatabaseMethods(uid: Constants.myUserId).addUserTag(newTag, index);
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  getMyStories() {
    storyStream = DatabaseMethods(uid: Constants.myUserId).getSenderStories(true);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    getMyStories();
    super.initState();
  }

  Widget menuItem({String label, icon, color = Colors.white}){
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.horizontal(left:Radius.circular(30)),
          color: Colors.black54,
      ),
      margin: EdgeInsets.only(left: 18),
      child: ListTile(
          title: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color),),
          trailing: iconContainer(
            icon:icon,
            contColor: Colors.black,
            horPad: 5,
            verPad: 5,
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      endDrawer: Container(
        width: width*0.81,
        margin: EdgeInsets.symmetric(vertical: height*0.05),
        child: Drawer(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.horizontal(left:Radius.circular(30)),
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  height: height*0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.menu, color: Colors.black,),
                        onPressed: (){
                          Navigator.pop(context);
                        },
                      ),
                      GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SettingsScreen()),
                            );
                          },
                          child: menuItem(label:'Settings', icon:Icons.settings,)
                      ),

                      GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AboutSpidrScreen()),
                            );
                          },
                          child: menuItem(label:'About', icon:Icons.info_rounded,)
                      ),

                      GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BackPackScreen()),
                            );
                          },
                          child: menuItem(label:'Backpack', icon:Icons.backpack_rounded,)
                      ),
                    ],
                  ),
                ),

              GestureDetector(
                  onTap: ()async{
                    bool hopOff = await showLogOutDialog(context);
                    if(hopOff != null && hopOff){
                      Navigator.pop(context);
                      Navigator.pop(context, true);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 1,
                        )
                      ],
                      borderRadius: BorderRadius.only(bottomLeft:Radius.circular(30)),
                    ),
                    padding: EdgeInsets.only(left: 18),
                    child: ListTile(
                        title: Text('Hop Off', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black,),),
                        trailing: iconContainer(
                          icon:Icons.logout,
                          contColor: Colors.black,
                          horPad: 5,
                          verPad: 5,
                        )
                    ),
                  )
              ),
            ],
            ),
          )
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            final ScaffoldState scaffold = Scaffold.maybeOf(context);
            final ModalRoute<dynamic> parentRoute = ModalRoute.of(context);
            final bool hasEndDrawer = scaffold?.hasEndDrawer ?? false;
            final bool canPop = parentRoute?.canPop ?? false;

            if (hasEndDrawer && canPop) {
              return BackButton();
            } else {
              return SizedBox.shrink();
            }
          },
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder(
        stream: DatabaseMethods().userCollection
            .doc(Constants.myUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasData && snapshot.data.data() != null){
            String quote = snapshot.data.data()["quote"];
            String profileImg = snapshot.data.data()["profileImg"];
            int imgIndex = snapshot.data.data()["anonImg"];
            String anonImg = imgIndex != null ? userMIYUs[imgIndex] : null;
            List tags = snapshot.data.data()["tags"];
            List banner = snapshot.data.data()["banner"];

            if(anonImg == null){
              DatabaseMethods(uid: Constants.myUserId).setUpAnonImg();
            }

            return Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    // physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            banner != null && banner.isNotEmpty ?
                            bannerSlide(
                              context:context,
                              height:height*0.35,
                              banner:banner,
                              userId:Constants.myUserId,
                              delTag: deleteMyTag,
                              editTag: addOrEditMyTag,
                              editAboutMe: editAboutMe,
                              formKey: formKey,
                              quoteController: quoteController,
                              tagController: tagController,
                            ) : GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => BannerScreen(
                                      userId: Constants.myUserId,
                                      delTag: deleteMyTag,
                                      editTag: addOrEditMyTag,
                                      editAboutMe: editAboutMe,
                                      formKey: formKey,
                                      quoteController: quoteController,
                                      tagController: tagController,
                                    )
                                ));
                              },
                              child: Container(
                                height: height*0.35,
                                width: MediaQuery.of(context).size.width,
                                color: Theme.of(context).scaffoldBackgroundColor,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(width: 54,),
                                Container(
                                  height: 81,
                                  width: 81,
                                  margin: EdgeInsets.only(top: height*0.275),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    // boxShadow: [circleShadow],
                                  ),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(4.5),
                                        child: avatarImg(profileImg, 36),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          if(!uploading){
                                            setState(() {
                                              uploading = true;
                                            });
                                            String imgUrl = await UploadMethods(profileImg: profileImg)
                                                .pickAndUploadMedia("USER_PROFILE_IMG", false);
                                            setState(() {
                                              uploading = false;
                                            });
                                            if(imgUrl != null){
                                              DatabaseMethods(uid: Constants.myUserId).replaceUserPic(imgUrl);
                                            }
                                          }
                                        },
                                        child: Align(
                                            alignment: Alignment.bottomRight,
                                            child: !uploading ? imgEditBtt() :
                                            SizedBox(
                                                height: 25,
                                                width: 25,
                                                child: sectionLoadingIndicator()
                                            )
                                        ),
                                      )
                                    ],
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () async{
                                    int newImgIndex = await showDialog(
                                        context: context,
                                        builder: (BuildContext context){
                                          return SelectAnonImgDialog(imgIndex);
                                        });
                                    if(newImgIndex != null && imgIndex != newImgIndex){
                                      DatabaseMethods(uid: Constants.myUserId).replaceUserAnonPic(newImgIndex);
                                    }
                                  },
                                  child: Container(
                                    height: 54,
                                    width: 54,
                                    margin: EdgeInsets.only(top: height*0.3),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0, 3), // changes position of shadow

                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      clipBehavior: Clip.none,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4.5),
                                          child: avatarImg(anonImg, 24),
                                        ),
                                        Positioned(
                                          top: 54,
                                          child: Image.asset("assets/icon/icons8-anonymous-mask-50.png",scale: 2.5),
                                        )
                                      ],
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),

                        Column(
                          children: [
                            Text(Constants.myName, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                            Text(Constants.myEmail, style: TextStyle(color: Colors.black),),
                          ],
                        ),

                        SizedBox(height: height*0.05,),

                        quote.isEmpty ? GestureDetector(
                          onTap: (){
                            showTextBoxDialog(
                                context: context,
                                text: "About Me",
                                textEditingController: quoteController,
                                errorText: "Sorry, this can not be empty",
                                editQuote: editAboutMe,
                                formKey: formKey
                            );
                          },
                          child: infoEditBtt(context:context, text:"About Me"),
                        ) : Container(
                          padding: EdgeInsets.symmetric(horizontal: 36),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                infoText(text:quote, textAlign: TextAlign.center),
                                SizedBox(width: 5,),
                                GestureDetector(
                                    onTap: (){
                                      showTextBoxDialog(
                                          context: context,
                                          text: "About Me",
                                          textEditingController: quoteController,
                                          errorText: "Sorry, about me can not be empty",
                                          editQuote: editAboutMe,
                                          formKey: formKey
                                      );
                                    },
                                    child: infoEditIcon()
                                )
                              ]
                          ),
                        ),

                        SizedBox(height: height*0.025,),

                        storyStreamWrapper(
                          storyStream: storyStream,
                          align: Alignment.center,
                        ),

                        SizedBox(height: height*0.015,),

                        Container(
                            height: 45,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            child: ProfileTagList(
                                editable: true,
                                tagController:tagController,
                                tags:tags,
                                editTag:addOrEditMyTag,
                                delTag: deleteMyTag,
                                formKey:formKey,
                                tagNum: tags.length < Constants.maxTags ? tags.length + 1 : Constants.maxTags
                            )
                        ),

                        SizedBox(height: height*0.05,),

                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 27),
                            child: groupList(Constants.myUserId)
                        )
                      ],
                    ),
                  ),
                ),

                Container(
                  height: 90,
                    decoration:BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.75) ,
                              Colors.black.withOpacity(0)
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter
                        )
                    )
                )
              ],
            );
          }else{
            return screenLoadingIndicator(context);
          }
        }
      ),
      // floatingActionButton: FloatingActionButton(
      //   elevation: 1.0,
      //   backgroundColor: Colors.orange,
      //   child: Icon(Icons.backpack_rounded, color: Colors.white,),
      //   onPressed: (){
      //     openBackpackBttSheet(context);
      //   },
      //
      // ),
    );
  }
}


