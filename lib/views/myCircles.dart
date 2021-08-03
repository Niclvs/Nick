import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/helper/functions.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/views/conversationScreen.dart';
import 'package:SpidrApp/views/groupProfilePage.dart';
import 'package:SpidrApp/views/viewJoinRequests.dart';
import 'package:SpidrApp/widgets/storiesListDisplay.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:SpidrApp/widgets/dialogWidgets.dart';
import 'package:SpidrApp/widgets/bottomSheetWidgets.dart';

class MyCirclesScreen extends StatefulWidget {
  final List mutedChats;
  MyCirclesScreen(this.mutedChats);
  @override
  _MyCirclesScreenState createState() => _MyCirclesScreenState();
}

class _MyCirclesScreenState extends State<MyCirclesScreen> {

  RefreshController refreshController = RefreshController(initialRefresh: false);

  Stream myGroupsStream;
  Stream mySpectateStream;
  Stream myInvitesStream;
  List<AlgoliaObjectSnapshot> suggestedGroups;
  String profileImg = '';

  Widget mySpecChatList() {
    return StreamBuilder(
        stream: mySpectateStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.docs.length > 0) {
              return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return SpecGroupTile(
                      snapshot.data.docs[index].data()["groupId"],
                      snapshot.data.docs[index].data()['numOfNewMsg'],
                      snapshot.data.docs[index].data()['createdAt'],
                    );
                  });
            } else {
              return Container(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: noItems(
                      icon:Icons.donut_small,
                      text:"no spectating circles yet",
                      mAxAlign:MainAxisAlignment.start
                  )
              );
            }
          } else {
            return sectionLoadingIndicator();
          }
        }
    );
  }

  Widget myPinnedGroupList() {
    return StreamBuilder(
        stream: DatabaseMethods(uid: Constants.myUserId).getMyGroups(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.docs.length > 0) {
              return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data.docs.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    String groupId = snapshot.data.docs[index].data()["groupId"];
                    return snapshot.data.docs[index].data()["pinned"] != null && snapshot.data.docs[index].data()["pinned"] ?
                    MyGroupTile(
                      groupId,
                      snapshot.data.docs[index].data()['joinRequests'],
                      snapshot.data.docs[index].data()['numOfNewMsg'],
                      snapshot.data.docs[index].data()['replies'],
                      snapshot.data.docs[index].data()['numOfUploads'],
                      snapshot.data.docs[index].data()['createdAt'],
                      true,
                      widget.mutedChats.contains(groupId),
                    ) : SizedBox.shrink();
                  });
            } else {
              return SizedBox.shrink();
            }
          } else {
            return SizedBox.shrink();
          }
        }
    );
  }

  Widget myGroupChatList() {
    return StreamBuilder(
        stream: DatabaseMethods(uid: Constants.myUserId).getMyGroups(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.docs.length > 0) {
              return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data.docs.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    String groupId = snapshot.data.docs[index].data()["groupId"];
                    return snapshot.data.docs[index].data()["pinned"] == null || !snapshot.data.docs[index].data()["pinned"] ?
                    MyGroupTile(
                      groupId,
                      snapshot.data.docs[index].data()['joinRequests'],
                      snapshot.data.docs[index].data()['numOfNewMsg'],
                      snapshot.data.docs[index].data()['replies'],
                      snapshot.data.docs[index].data()['numOfUploads'],
                      snapshot.data.docs[index].data()['createdAt'],
                      false,
                      widget.mutedChats.contains(groupId),
                    ) : SizedBox.shrink();
                  });
            } else {
              return Container(
                  height: 135,
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: noItems(
                      icon:Icons.donut_large_rounded,
                      text:"no joined circles yet",
                      mAxAlign:MainAxisAlignment.start
                  )
              );
            }
          } else {
            return sectionLoadingIndicator();
          }
        }
    );
  }

  acceptGroupInvite(String groupId, String hashTag, String groupState) async {
    DocumentSnapshot groupSnapshot = await DatabaseMethods().getGroupChatById(groupId);
    int numOfMem = groupSnapshot.data()['members'].length;
    double groupCap = groupSnapshot.data()['groupCapacity'];

    if (numOfMem < groupCap) {
      DatabaseMethods(uid: Constants.myUserId).toggleGroupMembership(groupId, "JOIN_PUB_GROUP_CHAT");
    } else {
      showJoinGroupAlertDialog(context, groupState, groupId, hashTag);
    }
  }

  requestJoinPvtGroup(String groupId, String hashTag, String groupState) async {
    DocumentSnapshot groupSnapshot = await DatabaseMethods().getGroupChatById(groupId);
    int numOfMem = groupSnapshot.data()['members'].length;
    double groupCap = groupSnapshot.data()['groupCapacity'];

    if (numOfMem < groupCap) {
      DatabaseMethods(uid: Constants.myUserId)
          .requestJoinGroup(groupId, Constants.myName, Constants.myUserId, Constants.myEmail, null);

      showCenterFlash(alignment: Alignment.center, context: context, text: 'You request has been sent');
    } else {
      showJoinGroupAlertDialog(context, groupState, groupId, hashTag);
    }
  }

  Widget inviteTile(String groupId, String groupState, String invitorName, String hashTag) {
    return Container(
        color: Colors.orange,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hashTag,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    )
                ),
                Text("From: " + invitorName,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    )
                ),
                Text(groupState,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: groupState == "invisible" ? Colors.black :
                      groupState == "public" ? Colors.green :
                      Colors.red
                  ),
                ),
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                if (groupState != "private") {
                  acceptGroupInvite(groupId, hashTag, groupState);
                } else {
                  requestJoinPvtGroup(groupId, hashTag, groupState);
                }
              },
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30)
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Text(groupState != "private" ? "Join" : "Request",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      )
                  )
              ),
            ),
            SizedBox(width: 10,),
            GestureDetector(
              onTap: () {
                DatabaseMethods(uid: Constants.myUserId).removeInvite(groupId);
              },
              child: Container(
                  child: Text("Ignore",
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black
                      )
                  )
              ),
            )
          ],
        )
    );
  }

  Widget myInvitesList() {
    return StreamBuilder(
        stream: myInvitesStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.docs.length > 0) {
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return inviteTile(
                    snapshot.data.docs[index].id,
                    snapshot.data.docs[index].data()["groupState"],
                    snapshot.data.docs[index].data()["invitorName"],
                    snapshot.data.docs[index].data()["hashTag"],
                  );
                });
          } else {
            return SizedBox.shrink();
          }
        }
    );
  }

  Widget sugGroupTile({
    String hashTag,
    String groupId,
    String admin,
    String groupState,
    String profileImg,
    bool anon,
    BuildContext context,
    bool preview,
    int createdAt,
    bool oneDay
  }) {
    int timeElapsed = getTimeElapsed(createdAt);
    bool expired = oneDay && timeElapsed / Duration.secondsPerDay >= 1;

    return GestureDetector(
      onTap: () {
        if (!expired) {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) =>
                  GroupProfileScreen(
                      groupId: groupId,
                      admin: admin,
                      fromChat: false,
                      preview: preview
                  )
          ));
        }
      },
      child: Column(
        children: [
          groupProfile(
              groupId: groupId,
              oneDay: oneDay,
              timeElapsed: timeElapsed,
              profileImg: profileImg
          ),
          groupStateIndicator(groupState, anon, MainAxisAlignment.center),
          Stack(
              children: [
                !expired ? StreamBuilder(
                    stream: DatabaseMethods().groupChatCollection
                        .doc(groupId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data.data() != null) {
                        bool onRequest = snapshot.data.data()["joinRequests"].containsKey(Constants.myUserId);
                        bool waitlisted = snapshot.data.data()["waitList"].containsKey(Constants.myUserId);
                        return borderedText(
                            hashTag,
                            onRequest ? Colors.grey :
                            waitlisted ? Colors.red :
                            Colors.black
                        );
                      } else {
                        return borderedText(hashTag, Colors.black);
                      }
                    }
                ) : borderedText("Expired", Colors.grey),
              ]
          ),
        ],
      ),
    );
  }

  Widget suggestionList() {
    if (suggestedGroups != null) {
      if (suggestedGroups.length > 0) {
        return ListView.builder(
            itemCount: suggestedGroups.length,
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              Map<String, dynamic> docData = suggestedGroups[index].data;
              return sugGroupTile(
                  groupId: suggestedGroups[index].objectID,
                  hashTag: docData["hashTag"],
                  admin: docData["admin"],
                  groupState: docData["chatRoomState"],
                  profileImg: docData["profileImg"],
                  anon: docData["anon"] != null && docData["anon"],
                  preview: true,
                  context: context,
                  createdAt: docData["createdAt"],
                  oneDay: docData["oneDay"] != null && docData["oneDay"]
              );
            });
      } else {
        return Container(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: noItems(
                icon:Icons.edit,
                text:"add or edit your tags",
                mAxAlign:MainAxisAlignment.start
            )
        );
      }
    } else {
      return sectionLoadingIndicator();
    }

  }

  getGroupChats() {
    myGroupsStream = DatabaseMethods(uid: Constants.myUserId).getMyGroups();
  }

  getSpectChats() {
    mySpectateStream = DatabaseMethods(uid: Constants.myUserId).getSpectatingChats();
  }

  getInvites() {
    myInvitesStream = DatabaseMethods(uid: Constants.myUserId).getMyInvites();
  }

  getSuggestion() {
    DatabaseMethods(uid: Constants.myUserId).suggestGroups().then((val) {
      if(mounted){
        setState(() {
          suggestedGroups = val;
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getGroupChats();
    getInvites();
    getSpectChats();
    getSuggestion();
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            myInvitesList(),
            sectionLabel("Suggestions", Colors.black, Colors.white),
            Container(
                height: 135.0,
                padding: EdgeInsets.only(left: 9),
                child: suggestionList()
            ),
            sectionLabel("Your Circles", Colors.orange, Colors.white),
            myPinnedGroupList(),
            myGroupChatList(),
            sectionLabel("Spectating", Colors.orange, Colors.white),
            Container(
                height: 135.0,
                padding: EdgeInsets.only(left: 9),
                child: mySpecChatList()
            ),
          ],
        ),
      ),
    );
  }
}

class MyGroupTile extends StatelessWidget {
  final String groupId;
  final Map joinRequests;
  final int numOfNewMsg;
  final Map replies;
  final int numOfUploads;
  final int createdAt;
  final bool pinned;
  final bool muted;

  MyGroupTile(
      this.groupId,
      this.joinRequests,
      this.numOfNewMsg,
      this.replies,
      this.numOfUploads,
      this.createdAt,
      this.pinned,
      this.muted
      );

  @override
  Widget build(BuildContext context){
    final TargetPlatform platform = Theme.of(context).platform;
    int numOfJoinReq = joinRequests != null ?
    joinRequests.keys.where((userId) => !Constants.myBlockList.contains(userId)).toList().length :
    0;
    Offset tapDownPos;
    return StreamBuilder(
        stream: DatabaseMethods().groupChatCollection
            .doc(groupId)
            .snapshots(),
        builder: (context, snapshot){
          if(snapshot.hasData && snapshot.data.data() != null){
            String hashTag = snapshot.data.data()['hashTag'];
            String admin = snapshot.data.data()['admin'];
            String profileImg = snapshot.data.data()['profileImg'];
            String groupState = snapshot.data.data()['chatRoomState'];
            bool anon = snapshot.data.data()['anon'] != null && snapshot.data.data()['anon'];

            bool oneDay = createdAt != null;
            int timeElapsed = oneDay ? getTimeElapsed(createdAt) : null;
            return GestureDetector(
              onTap: (){
                openCameraBttSheet(
                  context:context,
                  groupId:groupId,
                  hashTag:hashTag,
                );
              },
              onTapDown: (TapDownDetails details){
                tapDownPos = details.globalPosition;
              },
              onLongPress: ()async{
                RenderBox overlay = Overlay.of(context).context.findRenderObject();
                int value  = await showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      tapDownPos.dx,
                      tapDownPos.dy,
                      overlay.size.width - tapDownPos.dx,
                      overlay.size.height - tapDownPos.dy,
                    ),
                    items: [
                      PopupMenuItem(
                        value: 1,
                        child: Text(!pinned ? "Pin to Top" : "Unpin from Top"),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Text(!muted ? "Mute Notification" : "Unmute Notification"),
                      ),
                    ]
                );
                if(value == 1){
                  if(!pinned) DatabaseMethods(uid: Constants.myUserId).pinMyGroup(groupId);
                  else DatabaseMethods(uid: Constants.myUserId).unPinMyGroup(groupId);
                }else if (value == 2){
                  if(!muted) DatabaseMethods(uid: Constants.myUserId).muteMyGroup(groupId);
                  else DatabaseMethods(uid: Constants.myUserId).unMuteMyGroup(groupId);
                }
              },
              child: Container(
                height: 81,
                child: ListTile(
                  leading: GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>  GroupProfileScreen(
                                    groupId:groupId,
                                    admin:admin,
                                    fromChat:false,
                                    preview:false
                                )
                            )
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          groupProfile(groupId:groupId, oneDay:oneDay, timeElapsed:timeElapsed, profileImg:profileImg),
                          storyStreamWrapper(
                              storyStream:DatabaseMethods(uid: Constants.myUserId).getGroupStory(groupId),
                              height: 63,
                              width: 54,
                              tileHeight: 54,
                              tileWidth: 54,
                              iconSize: 18,
                              groupId: groupId,
                              singleDisplay: true,
                              align: Alignment.center
                          ),
                        ],
                      )
                  ),
                  title: Row(
                    children: [
                      Flexible(
                          child: GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) =>  GroupProfileScreen(
                                        groupId:groupId,
                                        admin:admin,
                                        fromChat:false,
                                        preview:false
                                    )
                                ));
                              },
                              child: Text(hashTag, style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold,),)
                          )
                      ),
                      SizedBox(width: 8,),
                      admin == Constants.myUserId ?
                      Container(
                        width: 10,
                        height: 10,
                        alignment: Alignment.topCenter,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor
                        ),
                      ) : SizedBox.shrink(),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      groupStateIndicator(groupState, anon, MainAxisAlignment.start),
                      Row(
                        children: [
                          numOfJoinReq > 0 && admin == Constants.myUserId ?
                          GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => JoinRequestsScreen(joinRequests, groupId, hashTag)
                                ));
                              },
                              child: iconNum(Icons.person_add, numOfJoinReq)
                          ) : SizedBox.shrink(),
                          pinned ? Icon(Icons.push_pin_rounded, color: Colors.grey, size: 13.5,) : SizedBox.shrink(),
                          muted ? Icon(Icons.notifications_off_rounded, color: Colors.grey, size: 13.5,) : SizedBox.shrink()
                        ],
                      ),
                    ],
                  ),
                  trailing: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      replies.length > 0 ?
                      iconNum(Icons.maps_ugc, replies.length) :
                      SizedBox.shrink(),
                      SizedBox(width: 15,),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => ConversationScreen(
                                  groupChatId:groupId,
                                  uid:Constants.myUserId,
                                  spectate:false,
                                  preview:false,
                                  initIndex: 0
                              )
                          ));
                        },
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Icon(
                                platform == TargetPlatform.iOS ?
                                CupertinoIcons.chat_bubble_fill :
                                Icons.send_rounded,
                                color: Colors.black,
                              ),
                            ),
                            numOfUploads != null && numOfUploads > 0 ?
                            Positioned(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                                )
                            ) : numOfNewMsg != null && numOfNewMsg > 0 ?
                            notifIcon(numOfNewMsg, false) : SizedBox.shrink()
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }else{
            return ListTile(
              leading: CircleAvatar(
                radius: 24,
              ),
              title: Text("#HASHTAG",
                style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold,),
              ),
              subtitle: Text("...",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.orange
                  )
              ),
              trailing: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                    platform == TargetPlatform.iOS ?
                    CupertinoIcons.chat_bubble_fill :
                    Icons.send_rounded,
                    color: Colors.black
                ),
              ),
            );
          }
        }
    );
  }
}


class SpecGroupTile extends StatelessWidget {
  final String groupId;
  final int numOfNewMsg;
  final int createdAt;

  SpecGroupTile(this.groupId, this.numOfNewMsg, this.createdAt);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: DatabaseMethods().groupChatCollection.doc(groupId).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasData && snapshot.data != null){
            if(snapshot.data.data() != null){
              var groupDS = snapshot.data;
              String profileImg = groupDS.data()["profileImg"];
              String hashTag = groupDS.data()["hashTag"];
              String groupState = groupDS.data()["chatRoomState"];
              bool anon = groupDS.data()['anon'];
              // bool oneDay = groupDS.data()['oneDay'] != null && groupDS.data()['ondDay'];
              // int createdAt = groupDS.data()['createdAt'];
              bool oneDay = createdAt != null;
              int timeElapsed = oneDay ? getTimeElapsed(createdAt) : null;

              return GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ConversationScreen(
                          groupChatId:groupId,
                          uid:Constants.myUserId,
                          spectate:true,
                          preview:false,
                          initIndex:0
                      )
                  ));
                },
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        groupProfile(groupId:groupId, oneDay:oneDay, timeElapsed:timeElapsed, profileImg:profileImg),
                        storyStreamWrapper(
                            storyStream:DatabaseMethods(uid: Constants.myUserId).getGroupStory(groupId),
                            height: 63,
                            width: 54,
                            tileHeight: 54,
                            tileWidth: 54,
                            iconSize: 18,
                            groupId: groupId,
                            singleDisplay: true,
                            align: Alignment.center
                        ),
                      ],
                    ),
                    groupStateIndicator(groupState, anon, MainAxisAlignment.center),
                    Stack(
                        children:[
                          borderedText(hashTag, Colors.orange),
                          numOfNewMsg > 0 ?
                          Positioned(
                              top: 5,
                              left: 15,
                              child: Container(
                                height: 20,
                                width: 20,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(40)
                                ),
                                child: Text("$numOfNewMsg",style:TextStyle(color:Colors.white, fontWeight: FontWeight.bold),),
                              )
                          ) : SizedBox.shrink(),
                        ]
                    ),
                  ],
                ),
              );
            }else{
              return SizedBox.shrink();
            }
          }else{
            return SizedBox.shrink();
          }
        }
    );
  }
}

