import 'package:SpidrApp/decorations/widgetDecorations.dart';
import 'package:SpidrApp/helper/functions.dart';

import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/views/conversationScreen.dart';
import 'package:SpidrApp/views/editGroup.dart';
import 'package:SpidrApp/widgets/mediaGalleryWidgets.dart';
import 'package:SpidrApp/widgets/membersListDisplay.dart';
import 'package:SpidrApp/widgets/profilePageWidgets.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:any_link_preview/any_link_preview.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:simple_url_preview/simple_url_preview.dart';

class GroupProfileScreen extends StatefulWidget {
  final String groupId;
  final String admin;
  final bool fromChat;
  final bool preview;

  GroupProfileScreen({this.groupId, this.admin, this.fromChat, this.preview});

  @override
  _GroupProfileScreenState createState() => _GroupProfileScreenState();
}

class _GroupProfileScreenState extends State<GroupProfileScreen>
    with SingleTickerProviderStateMixin {

  TabController tabController;
  ScrollController scrollController;

  // Stream mediaStream;
  // Stream audioStream;
  // Stream pdfStream;
  // Stream membersStream;
  // TextEditingController infoController;
  // TextEditingController tagController = new TextEditingController();

  List mediaQS;
  List audioQS;
  List pdfQS;
  List messageQS;

  bool isAdmin = false;
  bool isMember;
  bool anon;
  String hashTag = "";

  String info = "";
  String school = "School";
  String program = "Program";
  List tags = [];
  String groupState = "";
  String profileImg;

  List blockList;

  // final formKey = GlobalKey<FormState>();

  Widget mediaAndFileTile({
    Map imgObj,
    Map fileObj,
    List mediaGallery,
    String messageId,
    String sendBy,
    String senderId,
    String profileImg,
    int sendTime,
    int index
  }){

    Widget tile = mediaGallery == null ?
    mediaAndFileDisplay(
      context:context,
      imgObj: imgObj,
      fileObj: fileObj,
      mediaId: messageId,
      sendBy: sendBy,
      senderId: senderId,
      play: false,
      groupChatId: widget.groupId,
      showInfo: true,
      anon: anon,
      div: imgObj != null ? index % 7 == 0 ? 3/2 : 3 : 2,
      numOfLines: 3,
    ) : MediaGalleryTile(
      mediaGallery:mediaGallery,
      groupId:widget.groupId,
      messageId:messageId,
      senderId:senderId,
      sendBy:sendBy,
      profileIndex: index,
      startIndex: 0,
      anon: anon,
    );

    return Container(
      decoration: imgObj != null && imgObj["sticker"] != null && imgObj["sticker"] ? null : shadowEffect(15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: tile,
      ),
    );
  }


  Widget groupMediaList(){
    return groupState.isNotEmpty && groupState == "public" || (isMember != null && isMember) ?
    Padding(
      padding: const EdgeInsets.symmetric(horizontal:9.0),
      child: mediaQS.length > 0 ? StaggeredGridView.countBuilder(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 9.0,
              crossAxisSpacing: 9.0,
              itemCount: mediaQS.length,
              itemBuilder: (context, index) {
                Map imgObj = mediaQS[index].data()["imgObj"];
                List mediaGallery = mediaQS[index].data()["mediaGallery"];
                String messageId = mediaQS[index].id;
                String sendBy = mediaQS[index].data()["sendBy"];
                String senderId = mediaQS[index].data()["userId"];
                int sendTime = mediaQS[index].data()["time"];
                return mediaAndFileTile(
                    imgObj: imgObj,
                    messageId: messageId,
                    sendBy: sendBy,
                    senderId: senderId,
                    sendTime: sendTime,
                    mediaGallery: mediaGallery,
                    index: index
                );
              },
              staggeredTileBuilder: (index) {
                return StaggeredTile.count(
                    index % 7 == 0 ? 2 : 1,
                    index % 7 == 0 ? 2 : 1
                );
              }
          ) : noItems(
              icon:Icons.image_rounded,
              text:"no media yet",
              mAxAlign: MainAxisAlignment.center
          )
    ) : privateGroupSign(Theme.of(context).platform);
  }

  Widget groupAudioList(){
    return groupState.isNotEmpty && groupState == "public" || (isMember != null && isMember) ?
    Padding(
      padding: const EdgeInsets.symmetric(horizontal:9.0),
      child: audioQS.length > 0 ? StaggeredGridView.countBuilder(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 9.0,
              crossAxisSpacing: 9.0,
              itemCount: audioQS.length,
              itemBuilder: (context, index) {
                Map fileObj = audioQS[index].data()["fileObj"];
                String messageId = audioQS[index].id;
                String sendBy = audioQS[index].data()["sendBy"];
                String senderId = audioQS[index].data()["userId"];
                String profileImg = audioQS[index].data()["profileImg"];
                int sendTime = audioQS[index].data()["time"];
                return mediaAndFileTile(
                    fileObj: fileObj,
                    messageId: messageId,
                    sendBy: sendBy,
                    senderId: senderId,
                    profileImg: profileImg,
                    sendTime: sendTime,
                    index:index,
                );
              },
              staggeredTileBuilder: (index) {
                return StaggeredTile.count(1,1);
              }
          ) : noItems(
              icon:Icons.music_note_rounded,
              text:"no audios yet",
              mAxAlign:MainAxisAlignment.center
      )
      ) : privateGroupSign(Theme.of(context).platform);
  }

  Widget groupPDFList(){
    return groupState.isNotEmpty && groupState == "public" || (isMember != null && isMember) ?
    Padding(
      padding: const EdgeInsets.symmetric(horizontal:9.0),
      child: pdfQS.length > 0 ?
      StaggeredGridView.countBuilder(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 9.0,
              crossAxisSpacing: 9.0,
              itemCount: pdfQS.length,
              itemBuilder: (context, index) {
                Map fileObj = pdfQS[index].data()["fileObj"];
                String messageId = pdfQS[index].id;
                String sendBy = pdfQS[index].data()["sendBy"];
                String senderId = pdfQS[index].data()["userId"];
                String profileImg = pdfQS[index].data()["profileImg"];
                int sendTime = pdfQS[index].data()["time"];
                return mediaAndFileTile(
                    fileObj: fileObj,
                    messageId: messageId,
                    sendBy: sendBy,
                    senderId: senderId,
                    profileImg: profileImg,
                    sendTime: sendTime,
                    index: index,
                );
              },
              staggeredTileBuilder: (index) {
                return StaggeredTile.count(1,1);
              }
          ) : noItems(
              icon:Icons.insert_drive_file,
              text:"no PDFs yet",
              mAxAlign:MainAxisAlignment.center
          )
    ) : privateGroupSign(Theme.of(context).platform);
  }

  Widget urlTile({String senderId, String message}){
    String url = extractUrl(message);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          children: [
            userProfile(userId: senderId, anon: anon, blockAble: false),
            SizedBox(width: 5),
            anon == null || !anon ?
            Flexible(child: userName(userId: senderId, fontWeight: FontWeight.w600)) :
            SizedBox.shrink()
          ],
        ),
        urlPreview(context: context, url: url, textColor: Colors.orange, simpleUrl: true),
      ],
    );
  }

  Widget groupURLList(){
    return groupState.isNotEmpty && groupState == "public" || (isMember != null && isMember) ?
    Padding(
        padding: const EdgeInsets.symmetric(horizontal:9.0),
        child: messageQS.length > 0 ?
        StaggeredGridView.countBuilder(
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 9.0,
          crossAxisSpacing: 9.0,
          itemCount: messageQS.length,
            itemBuilder: (context, index) {
              String message = messageQS[index].data()["message"];
              String senderId = messageQS[index].data()["userId"];
              return urlTile(senderId:senderId, message:message);
            },
            staggeredTileBuilder: (index) {
              return StaggeredTile.count(1,1);
            }
        ) : noItems(
            icon:Theme.of(context).platform == TargetPlatform.android ?
            Icons.link_rounded :
            CupertinoIcons.link,
            text:"no URLs yet",
            mAxAlign:MainAxisAlignment.center
        )
    ) : privateGroupSign(Theme.of(context).platform);
  }

  getMedia(){
    DatabaseMethods().getGroupMedia(widget.groupId).then((mdQS){
      setState(() {
        mediaQS = mdQS.docs.where((mdDS) => !Constants.myBlockList.contains(mdDS.data()["userId"])).toList();
      });
    });
  }

  getAudio(){
    DatabaseMethods().getGroupAudio(widget.groupId).then((adQS){
      setState(() {
        audioQS = adQS.docs.where((adDS) => !Constants.myBlockList.contains(adDS.data()["userId"])).toList();
      });
    });
  }

  getPDF(){
    DatabaseMethods().getGroupPDF(widget.groupId).then((docQS){
      setState(() {
        pdfQS = docQS.docs.where((docDS) => !Constants.myBlockList.contains(docDS.data()["userId"])).toList();
      });
    });
  }

  getUrl(){
    DatabaseMethods().getGroupURL(widget.groupId).then((msgQS){
      setState((){
        messageQS = msgQS.docs.where((msgDS) => !Constants.myBlockList.contains(msgDS.data()["userId"])).toList();
    });
  });
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(vsync: this, length:4);
    scrollController = ScrollController();

    getMedia();
    getAudio();
    getPDF();
    getUrl();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController.dispose();
    scrollController.dispose();
  }

  TabBar get _tabBar => TabBar(
        unselectedLabelColor: Colors.orange,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.orange
        ),
        tabs: [
          tabBtt(Icons.image_rounded),
          tabBtt(Icons.music_note_rounded),
          tabBtt(Icons.insert_drive_file_rounded),
          tabBtt(
            Theme.of(context).platform == TargetPlatform.android ?
            Icons.link_rounded :
            CupertinoIcons.link,
          ),
        ],
        controller: tabController,
  );

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final TargetPlatform platform = Theme.of(context).platform;

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: DatabaseMethods().groupChatCollection
            .doc(widget.groupId)
            .snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            if(snapshot.data.data() != null &&
                (snapshot.data.data()["deleted"] == null || !snapshot.data.data()["deleted"])){

              var val = snapshot.data;
              isAdmin = widget.admin == Constants.myUserId;
              info = val.data()["about"];
              tags = val.data()["tags"];
              hashTag = val.data()["hashTag"];
              groupState = val.data()["chatRoomState"];
              school = val.data()["school"] != null && val.data()["school"].isNotEmpty ? val.data()["school"] : "School";
              program = val.data()["program"] != null && val.data()["program"].isNotEmpty ? val.data()["program"] : "Program";
              profileImg = val.data()["profileImg"];
              anon = val.data()["anon"];
              isMember = val.data()["members"].contains(Constants.myUserId);

              double groupCapacity = val.data()['groupCapacity'];
              List members = val.data()['members'];
              bool oneDay = val.data()['oneDay'] != null && val.data()['oneDay'];
              int createdAt = val.data()['createdAt'];
              int timeElapsed = getTimeElapsed(createdAt);

              return NestedScrollView(
                controller: scrollController,
                headerSliverBuilder: (BuildContext context, bool isScroller){
                  return[
                    SliverAppBar(
                      backgroundColor: Colors.white,
                      elevation: 0.0,
                      pinned: true,
                      floating: true,
                      expandedHeight: MediaQuery.of(context).size.height*0.9,
                      actions: [
                        isAdmin ?
                        IconButton(
                          icon: Icon(platform == TargetPlatform.android ? Icons.settings : CupertinoIcons.settings),
                          color: Colors.black,
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => EditGroupScreen(
                                    Constants.myUserId,
                                    widget.groupId,
                                    hashTag,
                                    profileImg,
                                    groupState,
                                    groupCapacity,
                                    members.length,
                                    anon,
                                    tags,
                                    info,
                                    oneDay,
                                    timeElapsed
                                )
                            ));
                          },
                        ) : SizedBox.shrink(),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            school != "School" && program != "Program" ?
                            schAndProgWrapper(school, program) :
                            SizedBox.shrink(),

                            Container(
                              height: MediaQuery.of(context).size.width/4,
                              width: MediaQuery.of(context).size.width/4,
                              child: Center(
                                  child: groupProfile(
                                      height:81,
                                      width:81,
                                      oneDay:oneDay,
                                      timeElapsed:timeElapsed,
                                      profileImg:profileImg,
                                      avatarSize: 36
                                  )
                              ),
                            ),
                            SizedBox(height: 5,),

                            Text(hashTag, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),

                            groupStateIndicator(groupState, anon, MainAxisAlignment.center),

                            SizedBox(height: height*0.045,),
                            info.isNotEmpty ? Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  infoText(text:info, textAlign: TextAlign.center),
                                ],
                              ),
                            ) : SizedBox.shrink(),
                            SizedBox(height: height*0.045,),

                            Container(
                                height: 45,
                                padding: EdgeInsets.symmetric(horizontal: 18),
                                alignment: Alignment.center,
                                child: ProfileTagList(
                                  editable:false,
                                  tags:tags,
                                  tagNum: Constants.maxTags,
                                )
                            ),

                            SizedBox(height: height*0.05,),

                            Container(
                                height: height*0.155,
                                width:MediaQuery.of(context).size.width*0.9,
                                alignment: Alignment.center,
                                child: memberList(
                                    context: context,
                                    edit: false,
                                    groupId: widget.groupId,
                                    admin: widget.admin,
                                    anon: anon != null && anon
                                )
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(vertical:height*0.025),
                              child: !widget.fromChat ?
                              GestureDetector(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => ConversationScreen(
                                            groupChatId:widget.groupId,
                                            uid:Constants.myUserId,
                                            spectate:false,
                                            preview:widget.preview,
                                            initIndex:0
                                        )
                                    )
                                    );
                                  },
                                  child: functionBtt(context, Colors.blueAccent, Icons.remove_red_eye_rounded, "View Chat")
                              ) : functionBtt(context, Colors.grey, Icons.access_time_rounded, "In Chat"),
                            )
                          ],
                        ),
                      ),
                      bottom: PreferredSize(
                        preferredSize: _tabBar.preferredSize,
                        child: ColoredBox(
                          color: Colors.transparent,
                          child: _tabBar,
                        ),
                      ),
                    )
                  ];
                },
                body: StreamBuilder(
                  stream: DatabaseMethods(uid: Constants.myUserId).getMyStream(),
                  builder: (context, snapshot) {
                    if(snapshot.hasData && snapshot.data.data() != null){
                      blockList = snapshot.data.data()["blockList"];
                      return TabBarView(
                        children: [
                          mediaQS != null ? groupMediaList() : sectionLoadingIndicator(),
                          audioQS != null ? groupAudioList() : sectionLoadingIndicator(),
                          pdfQS != null ? groupPDFList() : sectionLoadingIndicator(),
                          messageQS != null ? groupURLList() : sectionLoadingIndicator()
                        ],
                        controller: tabController,
                      );
                    }else{
                      return sectionLoadingIndicator();
                    }
                  }
                ),
              );
            }else{
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                   Icon(Icons.timer, color: Colors.grey),
                   Text("Expired", style: TextStyle(color: Colors.grey),)
                 ],
               ),
             );
            }
          }else{
            return screenLoadingIndicator(context);
          }

        }
      )
    );
  }

  Widget tabBtt(IconData icon){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 9),
      decoration: BoxDecoration(
          border: Border.all(
              color: Colors.orange,
              width: 2.0
          ),
          borderRadius: BorderRadius.circular(30)
      ),
      child: Icon(icon),
    );
  }
}
