import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/widgets/exploreMediaItem.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class CircleMediaScreen extends StatefulWidget {
  @override
  _CircleMediaScreenState createState() => _CircleMediaScreenState();
}

class _CircleMediaScreenState extends State<CircleMediaScreen> {
  PageController gcmdController = PageController();
  Stream gcMediaStr;

  String type = 'Media';

  TextEditingController searchController = new TextEditingController();

  Widget gcMediaList(){
    return StreamBuilder(
        stream: gcMediaStr,
        builder: (context, snapshot) {
          return snapshot.hasData ? snapshot.data != null && snapshot.data.hits.length > 0  ?
          PageView.builder(
            itemCount: snapshot.data.hits.length as int,
            scrollDirection: Axis.vertical,
            controller: gcmdController,
            itemBuilder: (context, index){
              Map<String, dynamic> docData = snapshot.data.hits[index].data;
              String mediaId = snapshot.data.hits[index].objectID;
              String senderId = docData["senderId"];
              String sendBy = docData["sendBy"];
              Map mediaObj = docData["mediaObj"];
              List mediaGallery = docData["mediaGallery"];
              String groupId = docData["groupId"];
              String hashTag = docData["hashTag"];
              List tags = docData["tags"];
              return groupMedia(
                  mediaObj,
                  mediaGallery,
                  groupId,
                  hashTag,
                  tags,
                  senderId,
                  sendBy,
                  mediaId,
              );
            },
          ) : Center(child:Text("no ${type.toLowerCase()} available", style: TextStyle(color:Colors.orange),)
          ) :sectionLoadingIndicator();
        }
    );
  }

  getGCMedia(){
    setState(() {
      gcMediaStr = DatabaseMethods().getGCMedia(type:type, searchTxt:searchController.text);
    });
  }

  // fetchGCMedia(){
  //   if(mdIndices.isNotEmpty){
  //     List<DocumentSnapshot> temp = DatabaseMethods().getGCMedia(mediaQS: mediaList, mdIndices: mdIndices);
  //     gcMedia.addAll(temp.map((DocumentSnapshot e) => groupMedia(
  //         e.data()["mediaObj"],
  //         e.data()["mediaGallery"],
  //         e.data()["groupId"],
  //         e.data()["hashTag"],
  //         e.data()["tags"],
  //         e.data()["senderId"],
  //         e.data()["sendBy"],
  //         e.id,
  //       )).toList());
  //       currentPage += 1;
  //   }
  //
  //   setState(() {});
  // }

  // setUp()async{
  //   QuerySnapshot mediaQS = await DatabaseMethods().mediaCollection
  //       .orderBy("sendTime", descending: true)
  //       .get();
  //
  //   int index = 0;
  //   mediaQS.docs.forEach((DocumentSnapshot mediaDS) {
  //     if(!Constants.myBlockList.contains(mediaDS.data()["senderId"]) && !Constants.myRemovedMedia.contains(mediaDS.id)){
  //       mediaList.add(mediaDS);
  //       mdIndices.add(index);
  //       index++;
  //     }
  //   });
  //   gcMedia = [];
  //   // mdIndices = [for(int i=0; i<mediaQS.docs.length; i+=1) i];
  //   fetchGCMedia();
  // }

  @override
  void initState() {
    // TODO: implement initState
    // gcmdController.addListener(() {
    //   setState(() {
    //     gcCurPage = gcmdController.page;
    //   });
    // });
    getGCMedia(); // for group media

    // setUp();
    // gcmdController.addListener(() {
    //   if(currentPage - (gcmdController.page/Constants.maxMediaLoad) <= 0.12 ||
    //       mdIndices.length/Constants.maxMediaLoad < 1){
    //     fetchGCMedia();
    //   }
    // });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TargetPlatform platform = Theme.of(context).platform;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: myAvatar(),
        backgroundColor: Colors.black,
        elevation: 0.0,
        centerTitle: true,
        title:

        // Transform.scale(scale:0.7,child: Image.asset("assets/icon/dicoverTitle.png")),

        Text (
            "Discover",
            style: platform == TargetPlatform.android ?
            GoogleFonts.originalSurfer(color: Colors.orange,  fontWeight: FontWeight.bold, fontSize: 18) :
            GoogleFonts.electrolize(color: Colors.orange,  fontWeight: FontWeight.bold, fontSize: 18)
        ),
        actions: [
          snippetBtt(context, platform)
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DropdownButton(
                  value: type,
                  icon: Icon(Icons.arrow_drop_down_rounded, color: Colors.orange,),
                  iconSize: 15,
                  elevation: 18,
                  onChanged: (val){
                    setState(() {
                      type = val;
                    });
                    getGCMedia();
                  },
                  items: ["Media","Audio","PDF"].map((e) =>
                      DropdownMenuItem(
                          value: e,
                          child: Text(
                              e,
                              style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14
                              )
                          )
                      )
                  ).toList(),
                ),
                Container(
                  height: 30,
                  width: MediaQuery.of(context).size.width*0.6,
                  child: TextField(
                    onChanged: (val){
                      getGCMedia();
                    },
                    controller: searchController,
                    style: TextStyle(color: Colors.orange, fontSize: 14),
                    cursorColor: Colors.orange,
                    decoration: InputDecoration(
                      suffixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.orange,
                        size: 20,
                      ),
                      hintText: "Search",
                      hintStyle: TextStyle(color: Colors.orange, fontSize: 14),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.orangeAccent),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.orangeAccent),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.orangeAccent),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
          Expanded(
            child: gcMediaList(),
          )
          // gcMedia != null ? Expanded(
          //     child: gcMedia.length > 0 ?
          //     PageView.builder(
          //       scrollDirection: Axis.vertical,
          //       controller: gcmdController,
          //       itemCount: gcMedia.length,
          //       itemBuilder: (BuildContext context, int index) {
          //         return gcMedia[index];
          //       },
          //     ) : Center(child: Image.asset("assets/icon/spidrCityScene.png"))
          // ) : screenLoadingIndicator(context),
        ],
      ),
    );
  }
}

Widget groupMedia(
    Map mediaObj,
    List mediaGallery,
    String groupId,
    String hashTag,
    List tags,
    String userId,
    String username,
    String mediaId,
    ){
  return StreamBuilder(
      stream: DatabaseMethods().groupChatCollection.doc(groupId).snapshots(),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          var groupDS = snapshot.data;
          String groupProfile;
          String groupState = "";
          String admin;
          bool anon;
          bool oneDay;
          int createdAt;
          bool isMember;
          bool expiredGroup = false;
          if(groupDS.data() != null && (groupDS.data()["deleted"] == null || !groupDS.data()["deleted"])){
            groupProfile = groupDS.data()["profileImg"];
            groupState = groupDS.data()["chatRoomState"];
            admin = groupDS.data()["admin"];
            anon = groupDS.data()["anon"];
            oneDay = groupDS.data()["oneDay"] != null && groupDS.data()["oneDay"];
            createdAt = groupDS.data()["createdAt"];
            isMember = groupDS.data()["members"].contains(Constants.myUserId);
          }else{
            expiredGroup = true;
          }
          return StreamBuilder(
              stream: DatabaseMethods().userCollection.doc(userId).snapshots(),
              builder: (context, snapshot) {
                if(snapshot.hasData && snapshot.data.data() != null){
                  String userProfile = snapshot.data.data()["profileImg"];
                  int imgIndex = snapshot.data.data()["anonImg"];
                  String anonImg = userMIYUs[imgIndex];
                  bool blocked = snapshot.data.data()["blockedBy"] != null && snapshot.data.data()["blockedBy"].contains(Constants.myUserId);
                  return exploreMedia(
                      context: context,
                      mediaObj: mediaObj,
                      mediaGallery: mediaGallery,
                      mediaId: mediaId,
                      groupId: groupId,
                      hashTag: hashTag,
                      groupProfile:groupProfile,
                      admin:admin,
                      oneDay: oneDay,
                      createdAt: createdAt,
                      groupState: groupState,
                      userId: userId,
                      userName: username,
                      userProfile: userProfile,
                      anonProfile: anonImg,
                      anon: anon,
                      blocked: blocked,
                      isMember: isMember,
                      expiredGroup: expiredGroup,
                  );
                }else{
                  return SizedBox.shrink();
                }
              }
          );
        }else{
          return sectionLoadingIndicator();
        }
      }
  );
}

