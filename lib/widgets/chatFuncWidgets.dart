import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:SpidrApp/widgets/bottomSheetWidgets.dart';


Widget filesPickerBtt({
  BuildContext context,
  TargetPlatform platform,
  String groupChatId,
  String personalChatId,
  bool friend,
  String contactId,
  bool disabled
}){
  return IconButton(
      icon: Icon(Icons.add_circle),
      onPressed: disabled == null || !disabled ? (){
        openUploadBttSheet(
            context:context,
            groupId:groupChatId,
            personalChatId: personalChatId,
            friend: friend,
            contactId: contactId,
            uploadTo: groupChatId != null ? "GROUP" : "PERSONAL"
        );
      } : null
  );
}

Widget cameraBtt({
  BuildContext context,
  TargetPlatform platform,
  String hashTag,
  String groupId,
  String personalChatId,
  bool friend,
  String contactId,
  bool disabled
}){
  return IconButton(
    icon: Icon(platform == TargetPlatform.android ?
    Icons.camera_alt :
    CupertinoIcons.camera_fill),
    iconSize: 25.0,
    color: Colors.black,
    onPressed: disabled == null || !disabled ? () {
      openCameraBttSheet(
          context: context,
          groupId: groupId,
          hashTag: hashTag,
          personalChatId: personalChatId,
          friend: friend,
          contactId: contactId,
      );
    } : null,
  );
}

Widget sendChatBtt({
  BuildContext context,
  TargetPlatform platform,
  Function sendMessage,
  Map replyInfo,
  bool disabled
}){
  return Container(
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.orange
    ),
    child: IconButton(
      icon : Icon(platform == TargetPlatform.android ? Icons.send : CupertinoIcons.arrow_up_circle),
      iconSize: 25.0,
      color: Colors.white,
      key: UniqueKey(),
      onPressed: disabled == null || !disabled ? () {
        if(replyInfo == null || replyInfo.isEmpty){
          sendMessage();
        }else{
          sendMessage(inChatReply: replyInfo);
        }
      } : null,
    ),
  );
}