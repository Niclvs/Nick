import 'dart:collection';

import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/helper/functions.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/services/fileShare.dart';
import 'package:SpidrApp/views/mediaViewScreen.dart';
import 'package:SpidrApp/views/sendMedia.dart';
import 'package:SpidrApp/widgets/dialogWidgets.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:SpidrApp/widgets/feedPageWidgets.dart';

class GroupChatMediaPageView extends StatefulWidget {
  final String groupId;
  final String hashTag;
  final bool anon;
  final String messageId;
  final int mediaIndex;

  GroupChatMediaPageView({this.groupId, this.hashTag, this.anon, this.messageId, this.mediaIndex});
  @override
  _GroupChatMediaPageViewState createState() => _GroupChatMediaPageViewState();
}

class _GroupChatMediaPageViewState extends State<GroupChatMediaPageView> {
  PageController pageController;
  QuerySnapshot mediaQS;
  LinkedHashMap mediaMap = LinkedHashMap();

  // Stream mediaStream;

  pageViewSetUp() async{
    mediaQS = await DatabaseMethods().getGroupFeed(widget.groupId);
    int index = 0;
    mediaQS.docs.forEach((DocumentSnapshot mediaDS) {
      if(!Constants.myBlockList.contains(mediaDS.data()["userId"])){
        mediaMap[mediaDS.id] = {"index":index, "data":mediaDS.data()};
        index++;
      }
    });

    pageController = new PageController(initialPage:mediaMap[widget.messageId]["index"]);
    setState(() {});


    // DocumentReference groupDocRef = DatabaseMethods().groupChatCollection.doc(widget.groupId);
    // DocumentReference chatDocRef = groupDocRef.collection('chats').doc(widget.messageId);
    // DocumentSnapshot chatSnapshot = await chatDocRef.get();
    //
    // await groupDocRef.collection('chats')
    //     .orderBy('time', descending: true)
    //     .where("feed", isEqualTo: true)
    //     .endAtDocument(chatSnapshot)
    //     .get()
    //     .then((value) => pageController = new PageController(initialPage: value.docs.length - 1));
    //
    // setState(() {
    //   mediaStream = DatabaseMethods().getGroupFeed(widget.groupId);
    // });
  }

  @override
  void initState() {
    // TODO: implement initState
    pageViewSetUp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: mediaMap.length > 0 ? PageView.builder(
              reverse: true,
              itemCount: mediaMap.length,
              scrollDirection: Axis.vertical,
              controller: pageController,
              itemBuilder: (context, index) {
                var mediaData = mediaMap[mediaMap.keys.elementAt(index)]["data"];

                String messageId = mediaMap.keys.elementAt(index);
                Map imgObj = mediaData["imgObj"];
                Map fileObj = mediaData["fileObj"];
                List mediaGallery = mediaData["mediaGallery"];
                String senderId = mediaData["userId"];
                int sendTime = mediaData["time"];


                // String messageId = snapshot.data.docs[index].id;
                // Map imgObj = snapshot.data.docs[index].data()["imgObj"];
                // Map fileObj = snapshot.data.docs[index].data()["fileObj"];
                // List mediaGallery = snapshot.data.docs[index].data()["mediaGallery"];
                // List replies = snapshot.data.docs[index].data()["replies"];
                // String senderId = snapshot.data.docs[index].data()["userId"];
                // int sendTime = snapshot.data.docs[index].data()["time"];

                return feedTile(
                  context,
                  imgObj,
                  fileObj,
                  mediaGallery,
                  senderId,
                  sendTime,
                  messageId,
                  widget.anon,
                  widget.groupId,
                  widget.hashTag,
                );

              }
          ) : screenLoadingIndicator(context)

    );
  }
}

// class PersonalChatMediaPageView extends StatefulWidget {
//   final String personalChatId;
//   final String messageId;
//   final int mediaIndex;
//
//   PersonalChatMediaPageView({this.personalChatId, this.messageId, this.mediaIndex});
//   @override
//   _PersonalChatMediaPageViewState createState() => _PersonalChatMediaPageViewState();
// }
//
// class _PersonalChatMediaPageViewState extends State<PersonalChatMediaPageView> {
//   PageController pageController;
//
//   Stream mediaStream;
//
//   pageViewSetUp() async{
//       DocumentReference personalChatDocRef = DatabaseMethods().personalChatCollection.doc(widget.personalChatId);
//       DocumentReference chatDocRef = personalChatDocRef.collection('messages').doc(widget.messageId);
//       DocumentSnapshot chatSnapshot = await chatDocRef.get();
//
//       await personalChatDocRef.collection('messages')
//           .orderBy('sendTime', descending: true)
//           .where("media", isEqualTo: true)
//           .endAtDocument(chatSnapshot)
//           .get()
//           .then((value) => pageController = new PageController(initialPage: value.docs.length - 1));
//
//       setState(() {
//         mediaStream = DatabaseMethods().getPersonalChatMedia(widget.personalChatId);
//       });
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     pageViewSetUp();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//         stream: mediaStream,
//         builder: (context, snapshot){
//           if(snapshot.hasData){
//             if(snapshot.data.docs.length > 0){
//               return PageView.builder(
//                   reverse: true,
//                   itemCount: snapshot.data.docs.length,
//                   scrollDirection: Axis.vertical,
//                   controller: pageController,
//                   itemBuilder: (context, index) {
//                     String senderId = snapshot.data.docs[index].data()["senderId"];
//                     String messageId = snapshot.data.docs[index].id;
//                     Map imgObj = snapshot.data.docs[index].data()["imgMap"];
//                     Map fileObj = snapshot.data.docs[index].data()["fileMap"];
//                     List mediaGallery = snapshot.data.docs[index].data()["mediaGallery"];
//                     bool video = imgObj != null && videoChecker(imgObj["imgName"]);
//
//                     return MediaViewScreen(
//                       senderId: senderId,
//                       // mediaUrl: imgObj != null ? imgObj['imgUrl'] : fileObj != null ? fileObj['fileUrl'] : null,
//                       // caption: imgObj != null ? imgObj['caption'] : fileObj != null ? fileObj['caption'] : null,
//                       // audioName: fileObj != null && audioChecker(fileObj['fileName']) ? fileObj['fileName'] : null,
//                       // pdfName: fileObj != null && pdfChecker(fileObj['fileName']) ? fileObj['fileName'] : null,
//                       // video: video,
//                       mediaObj: imgObj != null ? imgObj : fileObj != null ? fileObj : null,
//                       mediaId: messageId,
//                       showInfo: false,
//                       // gifs: imgObj != null ? imgObj['gifs'] : fileObj != null ? fileObj['gifs'] : null,
//                       mediaGallery: mediaGallery,
//                       mediaIndex: widget.mediaIndex,
//                       // mature: imgObj != null && imgObj['mature'] != null && imgObj['mature'],
//                     );
//                   }
//               );
//             }else{
//               return SizedBox.shrink();
//             }
//           }else{
//             return screenLoadingIndicator(context);
//           }
//         }
//     );
//   }
// }

class StoryPageView extends StatelessWidget {
  final int startIndex;
  final AsyncSnapshot snapshot;
  final int mediaIndex;
  StoryPageView(this.startIndex, this.snapshot, this.mediaIndex);

  @override
  Widget build(BuildContext context) {
    PageController  pageController = new PageController(initialPage: startIndex);
    return PageView.builder(
        itemCount: snapshot.data.docs.length,
        scrollDirection: Axis.vertical,
        controller: pageController,
        itemBuilder: (context, index){
          String storyId = snapshot.data.docs[index].id;
          String senderId = snapshot.data.docs[index].data()["senderId"];
          Map mediaObj = snapshot.data.docs[index].data()["mediaObj"];
          List mediaGallery = snapshot.data.docs[index].data()["mediaGallery"];
          bool anon = snapshot.data.docs[index].data()["anon"];
          String groupId = snapshot.data.docs[index].data()["groupId"];

          return MediaViewScreen(
            senderId: senderId,
            groupId: groupId,
            mediaId: storyId,
            mediaObj: mediaObj,
            showInfo: true,
            story: true,
            anon: anon,
            mediaGallery: mediaGallery,
            mediaIndex: mediaIndex,
          );
        }
    );
  }
}