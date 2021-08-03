import 'dart:io' show Platform;
import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'mediaViewScreen.dart';

class JoinRequestsScreen extends StatefulWidget {
  final Map joinRequests;
  final String groupId;
  final String hashTag;
  JoinRequestsScreen(this.joinRequests, this.groupId, this.hashTag);
  @override
  _JoinRequestsScreenState createState() => _JoinRequestsScreenState();
}

class _JoinRequestsScreenState extends State<JoinRequestsScreen> {

  Map<String, dynamic> joinRequests;
  bool loading = false;

  acceptRequest(String groupId, String username, String hashTag, String userId) async{

    DocumentSnapshot groupSnapshot = await DatabaseMethods().getGroupChatById(groupId);

    int numOfMem = groupSnapshot.data()['members'].length;
    double groupCap = groupSnapshot.data()['groupCapacity'];

    if(numOfMem < groupCap){
      setState(() {
        loading = true;
      });
      await DatabaseMethods(uid: userId).toggleGroupMembership(groupId, "ACCEPT_JOIN_REQ");
      setState(() {
        joinRequests.remove(userId);
        loading = false;
      });
      showCenterFlash(alignment: Alignment.center, context: context, text: 'Accepted');
    }else{
      showFullGroupAlertDialog(groupId, username, userId);
    }
  }

  declineRequest(String groupId, String userId)async{
    setState(() {
      loading = true;
    });
    await DatabaseMethods(uid: userId).declineJoinRequest(groupId);
    setState(() {
      joinRequests.remove(userId);
      loading = false;
    });
    showCenterFlash(alignment: Alignment.center, context: context, text: 'Declined');
  }

  Widget joinRequestTile(
      String groupId,
      String hashTag,
      String userId,
      String userName,
      Map imgObj
      ){
    return Container(
      color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            userProfile(userId: userId, blockAble: false),
            Text(userName, style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
            SizedBox(width: 10.0,),
            imgObj != null ? Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Container(
                  height: 36,
                  width: 36,
                  child: mediaAndFileDisplay(
                      context:context,
                      imgObj: imgObj,
                      mediaId: userId,
                      play: false,
                      showInfo: false
                  ),
                ),
              ),
            ) : SizedBox.shrink(),

            Spacer(),
            GestureDetector(
              onTap: (){
                if(!loading)
                  declineRequest(groupId, userId);
              },
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(30)
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Icon(Platform.isAndroid ? Icons.close : CupertinoIcons.xmark,color: Colors.white,)
              ),
            ),
            SizedBox(width: 10,),
            GestureDetector(
              onTap: (){
                if(!loading)
                  acceptRequest(groupId, userName, hashTag, userId);
              },
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(30)
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Icon(Platform.isAndroid ? Icons.check : CupertinoIcons.check_mark,color: Colors.white,)
              ),
            )
          ],
        )
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      joinRequests = widget.joinRequests;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text ("Join Requests", style:TextStyle(color:Colors.black, fontWeight: FontWeight.bold),),
          elevation: 0,
        ),

      body: Stack(
        children: [
          ListView.builder(
          itemCount: joinRequests.length,
          itemBuilder: (context, index){
            String userId = joinRequests.keys.elementAt(index);
            String username = joinRequests[userId]["username"];
            Map imgObj = joinRequests[userId]["imgObj"];
            return !Constants.myBlockList.contains(userId) ?
            joinRequestTile(
                widget.groupId,
                widget.hashTag,
                userId,
                username,
                imgObj
            ) : SizedBox.shrink();
          }),

          loading ?
          screenLoadingIndicator(context) :
          SizedBox.shrink()
        ],
      ),
    );
  }

  showFullGroupAlertDialog(String groupId, String username, String userId){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Sorry",style: TextStyle(color: Colors.orange)),
            content: Text(
                "Your group has reached its full capacity. Do you want to put "+username+" on the waitlist?"
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))
            ),
            actions: [
              TextButton(
                  onPressed:(){
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text("NO",style: TextStyle(color: Colors.red))
              ),
              TextButton(
                  onPressed:()async{
                    await DatabaseMethods(uid: userId).toggleGroupMembership(groupId, "ACCEPT_REQ_BUT_FULL");
                    setState(() {
                      joinRequests.remove(userId);
                    });
                    showCenterFlash(alignment: Alignment.center, context: context, text: 'Waitlisted');
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text("YES",style: TextStyle(color: Colors.green))
              ),
            ],
          );
        }
    );
  }
}

