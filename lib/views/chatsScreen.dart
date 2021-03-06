import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/views/myCircles.dart';
import 'package:SpidrApp/widgets/storiesListDisplay.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'createGroup.dart';
import 'myFriends.dart';
import 'package:SpidrApp/widgets/widget.dart';

class ChatsScreen extends StatefulWidget {
  final int initialPage;
  ChatsScreen({this.initialPage = 0});
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen>
    with SingleTickerProviderStateMixin {

  // TabController tabController;
  PageController pageController;
  ScrollController scrollController;

  int curPage;

  Stream storyStream;

  getStories(){
    setState(() {
      storyStream = DatabaseMethods(uid: Constants.myUserId).getReceiverStories();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    // tabController = TabController(length: 3, initialIndex: widget.initialPage, vsync: this);
    pageController = PageController(initialPage: widget.initialPage);
    scrollController = ScrollController();
    curPage = widget.initialPage;
    getStories();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final TargetPlatform platform = Theme.of(context).platform;

    return Scaffold(
      backgroundColor: Colors.white,
      body:StreamBuilder(
        stream: DatabaseMethods(uid: Constants.myUserId).getMyStream(),
        builder: (context, snapshot) {
          List mutedChats = [];
          List receivedFdReq = [];
          if(snapshot.hasData && snapshot.data.data() != null){
            mutedChats = snapshot.data.data()["mutedChats"] != null ? snapshot.data.data()["mutedChats"] : [];
            receivedFdReq = snapshot.data.data()["receivedFdReq"] != null ? snapshot.data.data()["receivedFdReq"] : [];
          }
          return NestedScrollView(
            controller: scrollController,
            headerSliverBuilder: (BuildContext context, bool isScroller){
              return[StreamBuilder(
                  stream: storyStream,
                  builder: (context, snapshot) {
                    return SliverAppBar(
                      leading: myAvatar(),
                      backgroundColor: Colors.white,
                      elevation: 0.0,
                      centerTitle: true,
                      title: Text ("SpIdr",
                          style:
                          platform == TargetPlatform.android ?
                          GoogleFonts.originalSurfer(color: Colors.orange,  fontWeight: FontWeight.bold, fontSize: 18) :
                          GoogleFonts.electrolize(color: Colors.orange,  fontWeight: FontWeight.bold, fontSize: 18)
                      ),
                      actions: [
                        snippetBtt(context, platform)
                      ],
                      pinned: true,
                      expandedHeight: snapshot.hasData && snapshot.data != null && snapshot.data.docs.length > 0 ? 200 : null,
                      flexibleSpace: snapshot.hasData && snapshot.data != null ?
                      FlexibleSpaceBar(
                        background: Padding(
                          padding: const EdgeInsets.only(top:27.0),
                          child: storyList(
                              snapshot: snapshot,
                              align: Alignment.center
                          ),
                        ),
                      ) : null,

                      bottom: PreferredSize(
                        preferredSize: Size.fromHeight(45),
                        child: Container(
                            height: 45,
                            child:Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    tabItem(Icons.donut_large_rounded, "Circles", 0),
                                    StreamBuilder(
                                        stream: DatabaseMethods().userCollection
                                            .doc(Constants.myUserId)
                                            .collection('groups')
                                            .where('numOfNewMsg', isGreaterThan: 0)
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          return snapshot.hasData && snapshot.data.docs.length > 0 ?
                                          Icon(Icons.circle, size:9, color: Colors.orange) :
                                          SizedBox.shrink();
                                        }
                                    )
                                  ],
                                ),

                                VerticalDivider(color: Colors.black54, thickness: 1.5, width: 18, indent: 9, endIndent: 9,),

                                Stack(
                                  children: [
                                    tabItem(Icons.auto_awesome,"Friends", 1),
                                    StreamBuilder(
                                        stream: DatabaseMethods().userCollection
                                            .doc(Constants.myUserId)
                                            .collection('friends')
                                            .where('numOfNewMsg', isGreaterThan: 0)
                                            .snapshots(),
                                        builder: (context, friendMsg) {
                                          return StreamBuilder(
                                              stream: DatabaseMethods().userCollection
                                                  .doc(Constants.myUserId)
                                                  .collection('replies')
                                                  .where('numOfNewMsg', isGreaterThan: 0)
                                                  .snapshots(),
                                              builder: (context, replyMsg) {
                                                return receivedFdReq.length > 0 || friendMsg.hasData && replyMsg.hasData &&
                                                    (friendMsg.data.docs.length > 0 || replyMsg.data.docs.length > 0) ?
                                                Icon(Icons.circle, size:9, color: Colors.orange) :
                                                SizedBox.shrink();
                                              }
                                          );
                                        }
                                    )
                                  ],
                                ),

                              ],
                            )
                        ),
                      ),

                    );
                  }
                ),
              ];
            },
            body: PageView(
                  controller: pageController,
                  onPageChanged: (int page){
                    setState(() {
                      curPage = page;
                    });
                  },
                  children: <Widget>[
                    MyCirclesScreen(mutedChats),
                    MyFriendsScreen(mutedChats)
                  ],
                )
          );
        }
      ),

      floatingActionButton: curPage == 0 ? FloatingActionButton(
        elevation: 1.0,
        backgroundColor: Colors.orange,
        child: Icon(Icons.add, color: Colors.white,),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => CreateGroupScreen(Constants.myUserId)
          ));
        },
      ) : null,
    );
  }

  Widget tabItem(icon, String label, int index){
    return GestureDetector(
      onTap: (){
        pageController.jumpToPage(index);
        setState(() {
          curPage = index;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color:curPage == index ? Colors.black: Colors.grey),
          SizedBox(width: 5,),
          Text(
            label, style: TextStyle(
              fontWeight: curPage == index ? FontWeight.bold : null,
              color: curPage == index ? Colors.black: Colors.grey
          )
          )
        ],
      ),
    );
  }
}
