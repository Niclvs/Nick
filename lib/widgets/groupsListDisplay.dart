import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/views/groupProfilePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

Widget groupTile(
    BuildContext context,
    String groupId,
    String hashTag,
    String admin,
    String profileImg,
    String groupState,
    bool anon,
    String school,
    String program,
    ){
  return GestureDetector(
    onTap: (){
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => GroupProfileScreen(
              groupId:groupId,
              admin:admin,
              fromChat:false,
              preview: true
          )
      ));
    },
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        profileDisplay(profileImg),
        borderedText(hashTag, Colors.black),
        groupStateIndicator(groupState, anon, MainAxisAlignment.center)
      ],
    ),
  );
}


Widget groupList(String userId){
  return StreamBuilder(
    stream: DatabaseMethods(uid: userId).getUserChats(),
    builder: (context, snapshot){
      if(snapshot.hasData){
        if(snapshot.data.docs.length > 0){
          return StaggeredGridView.countBuilder(
              padding: EdgeInsets.zero,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data.docs.length,
              crossAxisCount: 2,
              mainAxisSpacing: 9.0,
              crossAxisSpacing: 9.0,
              itemBuilder: (context, index) {
                String groupId = snapshot.data.docs[index].id;
                return StreamBuilder(
                    stream: DatabaseMethods().groupChatCollection
                        .doc(groupId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if(snapshot.hasData && snapshot.data.data() != null){
                        String hashTag = snapshot.data.data()["hashTag"];
                        String admin = snapshot.data.data()["admin"];
                        String profileImg = snapshot.data.data()["profileImg"];
                        String groupState = snapshot.data.data()["chatRoomState"];
                        bool anon = snapshot.data.data()["anon"];
                        String school = snapshot.data.data()["school"];
                        String program = snapshot.data.data()["program"];
                        return groupState != "invisible" ?
                        groupTile(
                          context,
                          groupId,
                          hashTag,
                          admin,
                          profileImg,
                          groupState,
                          anon != null && anon,
                          school,
                          program,
                        ) : SizedBox.shrink();
                      }else{
                        return SizedBox.shrink();
                      }
                    }
                );
              },
              staggeredTileBuilder: (index) => StaggeredTile.fit(1)
          );
        }else{
          return SizedBox.shrink();
        }
      }else{
        return sectionLoadingIndicator();
      }
    },
  );
}