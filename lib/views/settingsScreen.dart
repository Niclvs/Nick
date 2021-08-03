import 'package:SpidrApp/decorations/widgetDecorations.dart';
import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/widgets/bottomSheetWidgets.dart';
import 'package:SpidrApp/widgets/dialogWidgets.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  bool notifOff;

  setUpMyInfo()async{
    DocumentSnapshot myDS = await DatabaseMethods(uid: Constants.myUserId).getUserById();
    setState(() {
      notifOff = myDS.data()["notifOff"] != null && myDS.data()["notifOff"];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    setUpMyInfo();
    super.initState();
  }

  Widget notificationTile(){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          color: Colors.white,
          boxShadow: [
            circleShadow
          ]
      ),
      child: ListTile(
        title: Text("Notification", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),),
        trailing: notifOff != null ?
        Switch(
          value: !notifOff,
          onChanged: (value){
            setState(() {
              notifOff=!value;
            });
            if(notifOff)
              DatabaseMethods(uid: Constants.myUserId).turnOffNotif();
            else
              DatabaseMethods(uid: Constants.myUserId).turnOnNotif();
          },
          activeTrackColor: Colors.black54,
          activeColor: Colors.black,
        ) : SizedBox.shrink(),
      ),
    );
  }

  Widget clearSearchTile(){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          color: Colors.white,
          boxShadow: [
            circleShadow
          ]
      ),
      child: ListTile(
        title: Text("Clear Search History", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),),
        trailing: iconContainer(
          icon:Icons.history_rounded,
          contColor: Colors.black,
          horPad: 5,
          verPad: 5,
        ),
        onTap: () async{
          bool clear = await showClearSearchDialog(context);
          if(clear != null && clear){
            DatabaseMethods(uid: Constants.myUserId).clearRecentSearch();
            showCenterFlash(alignment: Alignment.center, context: context, text: 'Cleared');
          }
        },
      ),
    );
  }

  Widget blockListTile(){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          color: Colors.white,
          boxShadow: [
            circleShadow
          ]
      ),
      child: ListTile(
        title: Text("Blocked List", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),),
        trailing: iconContainer(
          icon:Icons.block_rounded,
          contColor: Colors.red,
          horPad: 5,
          verPad: 5,
        ),
        onTap: (){
          openBlockListBttSheet(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Icon(Icons.settings, color: Colors.black,),
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              notificationTile(),
              clearSearchTile(),
              blockListTile(),
            ],
          ),
        )

    );
  }
}
