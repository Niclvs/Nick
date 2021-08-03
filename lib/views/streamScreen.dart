import 'dart:async';
import 'dart:math';

import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/views/conversationScreen.dart';
import 'package:SpidrApp/views/search.dart';
import 'package:SpidrApp/widgets/dialogWidgets.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class StreamScreen extends StatefulWidget {
  @override
  _StreamScreenState createState() => _StreamScreenState();
}

class _StreamScreenState extends State<StreamScreen>
    with WidgetsBindingObserver {
  PageController controller = PageController();
  PageController pageController = PageController();
  ItemScrollController scrollController = ItemScrollController();

  Stream groupStream;

  List<String> groupTags = [];
  String selTag = '';

  bool creating = false;
  bool onGenCir = false;

  bool openKeyBoard = false;
  bool loading = true;

  // bool lastPage = false;
  // bool searchBar = false;
  // TextEditingController searchTextController = TextEditingController();

  getGroups(){
    groupStream = DatabaseMethods().getPublicGroup(selTag, selTag.isEmpty);
  }

  buildGroupTags() async{
    List tags = await DatabaseMethods().getSugTags();
    if(mounted){
      setState(() {groupTags = tags; loading = false; selTag = selTag.isNotEmpty ? tags[0] : '';});
      getGroups();
    }
  }

  resetGroupStream()async{
    setState(() {loading = true;});
    await buildGroupTags();
    if(selTag.isNotEmpty)
      Timer(
        Duration(milliseconds: 100),
            () => pageController.jumpToPage(1),
      );
  }

  Widget genCircleBtt(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        !creating ? IconButton(
            onPressed: () async{
              DateTime now = DateTime.now();
              Random random = new Random();
              String profileImg = groupMIYUs[random.nextInt(groupMIYUs.length)];

              String hashTag = await showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return CreateHashTagDialog(selTag);
                  });

              if(hashTag != null){
                setState(() {creating = true;});
                await DatabaseMethods(uid: Constants.myUserId).createGroupChat(
                    hashTag:!hashTag.startsWith("#") ? "#"+hashTag.toUpperCase() : hashTag.toUpperCase(),
                    username:Constants.myName,
                    chatRoomState:"public",
                    time:now.microsecondsSinceEpoch,
                    groupCapacity:50,
                    groupPic:profileImg,
                    anon:true,
                    oneDay: true,
                    tags: [selTag]
                );
                Timer(
                    Duration(milliseconds: 4500), () {
                      getGroups();
                      setState(() {creating = false;});
                      if(controller.hasClients)
                        controller.animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                });
              }},
            icon: Container(
              foregroundDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.deepOrangeAccent],
                    begin: Alignment(0, 0),
                    end: Alignment(0, 1),
                  ),
                  backgroundBlendMode: BlendMode.screen
              ),
              child: Icon(Icons.add_circle_rounded),
            ),
            iconSize: 75,
            color: Colors.black
        ) : sectionLoadingIndicator(),

        SizedBox(height: 10,),
        Text("Start Conversation",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black54,
                offset: Offset(1, 1.5),
                blurRadius: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget groupChatsList(){
    final width = MediaQuery.of(context).size.width;
    return StreamBuilder(
        stream: groupStream,
        builder: (context, snapshot) {
          if(!loading && snapshot.hasData && snapshot.data != null){
              return PageView.builder(
                  physics:BouncingScrollPhysics(),
                  controller: pageController,
                  itemCount: groupTags.length + 1,
                  onPageChanged: (int index){
                    setState(() {
                      // lastPage = index == groupTags.length;
                      selTag = index == 0 ? '' : groupTags[index-1];
                    });
                    getGroups();
                    if(index > 0) scrollController.jumpTo(index: index-1);
                  },
                  itemBuilder: (context, index) {
                    if(snapshot.data.hits.length > 0){
                      int numOfHits = snapshot.data.hits.length as int;
                      int itemCount = selTag.isNotEmpty ? numOfHits + 1 : numOfHits;
                      return PageView.builder(
                          itemCount: itemCount,
                          scrollDirection: Axis.vertical,
                          controller: controller,
                          itemBuilder: (context, index){
                            if(index < numOfHits){
                              return Column(
                                children: [
                                  Expanded(
                                    child: ConversationScreen(
                                      groupChatId:snapshot.data.hits[index].objectID,
                                      uid:Constants.myUserId,
                                      spectate:false,
                                      preview:true,
                                      initIndex: 0,
                                    ),
                                  ),
                                  !openKeyBoard ? itemCount > 1 && index < itemCount - 1 ?
                                  GestureDetector(
                                      onTap: (){
                                        controller.nextPage(duration: Duration(milliseconds: 150), curve:Curves.easeIn);
                                      },
                                      child: Icon(Icons.keyboard_arrow_down)
                                  ) : Divider(color: Colors.black, thickness: 3, indent: width*0.475, endIndent: width*0.475,) :
                                  SizedBox.shrink(),
                                ],
                              );
                            }else{
                              return genCircleBtt();
                            }
                          }
                      );
                    } else{
                      if(selTag.isNotEmpty) return genCircleBtt();
                      else return Center(child: Image.asset("assets/icon/vector-creator (1).png"));
                    }
                }
              );
          }else{
            return sectionLoadingIndicator();
          }
        }
    );
  }

  @override
  void didChangeMetrics() {
    // TODO: implement didChangeMetrics
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    setState(() {openKeyBoard = bottomInset > 0.0;});
    super.didChangeMetrics();
  }

  @override
  void initState() {
    // TODO: implement initState
    buildGroupTags();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TargetPlatform platform = Theme.of(context).platform;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: myAvatar(),
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30)
          ),
          child: TextField(
            readOnly: true,
            onTap: (){
              Navigator.push(context, PageRouteBuilder(
                  pageBuilder: (_,__,___) =>  SearchScreen()
              ));
            },
            decoration: InputDecoration(
                icon: Icon(Icons.search),
                border: InputBorder.none,
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.grey)
            ),
          ),
        ),
        actions: [
          snippetBtt(context, platform),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 45,
            padding: EdgeInsets.symmetric(horizontal: 9, vertical: 9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: (){
                    setState(() {selTag = '';});
                    getGroups();
                    pageController.jumpToPage(0);
                  },
                  child: tagTile(
                    all:"24 hrs",
                    borderColor:selTag.isNotEmpty ? Colors.white : Colors.orange,
                    textColor:selTag.isNotEmpty ? Colors.orange : Colors.white,
                  ),
                ),
                Flexible(
                  child:
                  // !searchBar ?
                  !loading ? groupTags.length > 0 ?
                  ScrollablePositionedList.builder(
                      itemScrollController: scrollController,
                      physics: BouncingScrollPhysics(),
                      itemCount: groupTags.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index){
                        return GestureDetector(
                          onTap: (){
                            setState(() {selTag = groupTags[index];});
                            getGroups();
                            pageController.jumpToPage(index+1);
                            scrollController.jumpTo(index: index);
                          },
                          child:tagTile(
                            tag:groupTags[index],
                            borderColor:selTag != groupTags[index] ? Colors.white : Colors.orange,
                            textColor:selTag != groupTags[index] ? Colors.orange : Colors.white,
                          ),
                        );
                      }
                  ) : SizedBox.shrink() : sizedLoadingIndicator(size: 18, strokeWidth: 1.5)
                ),
                GestureDetector(
                  onTap: (){
                    resetGroupStream();
                  },
                    child: Icon(Icons.refresh_rounded, color: Colors.orange)
                ),
              ],
            ),
          ),
          Expanded(
              child:groupChatsList()
          ),
        ],
      ),
    );
  }
}

