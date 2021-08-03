import 'dart:math';

import 'package:SpidrApp/decorations/widgetDecorations.dart';
import 'package:SpidrApp/helper/functions.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/views/conversationScreen.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:SpidrApp/widgets/dialogWidgets.dart';

class CreateGroupScreen extends StatefulWidget {
  final String uid;
  CreateGroupScreen(this.uid);

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  bool anon = true;
  bool oneDay = true;
  final formKey = GlobalKey<FormState>();
  TextEditingController hashTagController = new TextEditingController();

  double groupCapacity = 20;
  bool validHashTag = true;

  bool creating = false;
  int randNum;
  String profileImg;

  int state = 1;
  PageController controller;

  List tags = [];

  createChatAndStartConvo() async{

    setState(() {
      creating = true;
    });

    String hashTag = hashTagController.text;
    hashTag = !hashTag.startsWith("#") ? "#" + hashTagController.text : hashTag;
    String chatRoomState = state == 1 ? "public" : state == 2 ? "private" : "invisible";

    DateTime now = DateTime.now();
    DatabaseMethods(uid: widget.uid).createGroupChat(
      hashTag:hashTag.toUpperCase(),
      username:Constants.myName,
      chatRoomState:chatRoomState,
      time:now.microsecondsSinceEpoch,
      groupCapacity:groupCapacity,
      groupPic:profileImg,
      anon:anon,
      tags: tags,
      oneDay: oneDay
    ).then((groupChatId) {
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) =>
              ConversationScreen(
                  groupChatId:groupChatId,
                  uid:widget.uid,
                  spectate:false,
                  preview:false,
                  initIndex:0
              )
      ));
    }, onError: (error){
      print(error);
    });

    hashTagController.text = "";
    setState(() {
      creating = false;
    });

  }

  @override
  void initState() {
    // TODO: implement initState
    Random random = new Random();
    randNum = random.nextInt(groupMIYUs.length);
    controller = PageController(
        initialPage: randNum,
        keepPage: false,
        viewportFraction: 0.5
    );
    setState(() {
      profileImg = groupMIYUs[randNum];
    });
    super.initState();
  }


  Widget mainText(String text){
    return Text(
      text,
      style: TextStyle(decoration: TextDecoration.underline,
        color: Colors.black,fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height*0.85,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.width/4.5,
                            width: MediaQuery.of(context).size.width/4.5,
                            child: profileImg != null ?
                            Stack(
                              children: [
                                Center(
                                  child: CircleAvatar(
                                    radius: 36,
                                    backgroundImage: AssetImage(profileImg),
                                  ),
                                ),
                              ],
                            ) : SizedBox.shrink(),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height*0.05,
                            child: miyuList(),
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/icon/icons8-anonymous-mask-50.png",scale: 2.5),
                          SizedBox(width: 10,),
                          Text(
                            "Anonymity",
                            style: GoogleFonts.varelaRound(color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.bold)
                          ),
                          SizedBox(width: 5,),
                          Switch(
                            value: anon,
                            onChanged: (value){
                              setState(() {
                                anon=value;
                              });
                            },
                            activeTrackColor: Colors.black54,
                            activeColor: Colors.black,
                          ),
                        ],
                      ),

                      Form(
                        key: formKey,
                        child: TextFormField(
                          textCapitalization: TextCapitalization.characters,
                          style: TextStyle(color: Colors.black),
                          controller: hashTagController,
                          onChanged: (val){
                            setState(() {
                              validHashTag = val.length <= 18 && !emptyStrChecker(val);
                            });
                          },
                          validator: (val){
                            return val.length > 18 ? "Maximum length 18" :
                            emptyStrChecker(val) ? "Please enter a hashTag" :
                            null;
                          },
                          decoration: hashTagFromDec(hashTagController.text.length, validHashTag),
                        )
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.timer, color: Colors.orange, size: 22.5,),
                          SizedBox(width: 10,),
                          Text(
                              "24 hrs",
                              style: GoogleFonts.varelaRound(color: Colors.orange, fontSize: 13.5, fontWeight: FontWeight.bold)
                          ),
                          SizedBox(width: 5,),
                          Switch(
                            value: oneDay,
                            onChanged: (value){
                              setState(() {
                                oneDay=value;
                              });
                            },
                            activeTrackColor: Colors.orangeAccent,
                            activeColor: Colors.orange,
                          ),
                        ],
                      ),

                      Column(
                        children: [
                          RadioListTile(
                            activeColor: Colors.orange,
                            value: 1,
                            groupValue: state,
                            title:Text("Public"),
                            onChanged: (T) {
                              setState(() {
                                state = T;
                              });
                            },
                          ),
                          RadioListTile(
                            activeColor: Colors.orange,
                            value: 2,
                            groupValue: state,
                            title: Text("Private"),
                            onChanged: (T) {
                              setState(() {
                                state = T;
                              });
                            },
                          ),
                          RadioListTile(
                            activeColor: Colors.orange,
                            value: 3,
                            groupValue: state,
                            title: Text("Invisible"),
                            onChanged: (T) {
                              setState(() {
                                state = T;
                              });
                            },
                          ),
                        ],
                      ),

                      Column(
                        children: [
                          Slider(
                            activeColor: Colors.orange,
                            value: groupCapacity,
                            min: 5,
                            max: 50,
                            divisions: 9,
                            onChanged: (newCapacity){
                              setState(() {
                                groupCapacity = newCapacity;
                              });
                            },
                            label: "$groupCapacity",
                          ),
                          Text("Circle Limit (50)", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                        ],
                      ),
                      // ignore: deprecated_member_use
                      FlatButton(
                        onPressed: () async{
                          if(!creating){
                            if(formKey.currentState.validate()){
                              if(state == 1){
                                tags = await showDialog(
                                    context: context,
                                    builder: (BuildContext context){
                                      return AddTagOnCreateDialog();
                                    }
                                );
                                if(tags != null){
                                  createChatAndStartConvo();
                                }
                              }else{
                                createChatAndStartConvo();
                              }
                            }
                          }
                        },
                        child: mainText("Create Circle"),
                      ),
                    ],
                  ),
                ),
              ),
              creating ?
              screenLoadingIndicator(context) :
              SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget miyuList(){
    return PageView.builder(
        itemCount: groupMIYUs.length,
        controller: controller,
        onPageChanged: (val){
          setState(() {
            profileImg = groupMIYUs[val];
          });
        },
        itemBuilder: (context, index){
          return miyuDisplay(groupMIYUs, index);
        }
    );
  }
}
