import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/views/userProfilePage.dart';
import 'package:SpidrApp/widgets/searchWidgets.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:flutter/material.dart';

class UsersList extends StatefulWidget {
  final String searchText;
  UsersList(this.searchText);
  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {

  List friends;
  List receivedFdReq;
  List sentFdReq;
  List blockList;
  List recentSearch;
  Stream usersStream;

  searchUsers(String searchText){
    setState(() {
      usersStream = DatabaseMethods().searchUsers(searchText);
    });
  }

  Widget searchUserTile(
      String userId,
      bool recent
      ) {

      bool befriended = friends != null && friends.contains(userId);
      bool sentReq = sentFdReq != null && sentFdReq.contains(userId);
      bool receivedReq = receivedFdReq != null && receivedFdReq.contains(userId);
      bool blocked = blockList != null && blockList.contains(userId);

        return GestureDetector(
          onTap: (){
            if(!recent) DatabaseMethods(uid: Constants.myUserId).addRecentSearch("reUserSearch", userId);
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => UserProfileScreen(userId:userId)
            ));
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width*0.5,
                  child: Row(
                    children: [
                      userProfile(userId: userId, toProfile: false),
                      SizedBox(width: 10,),
                      Flexible(child: userName(userId: userId))
                    ],
                  ),
                ),
                Spacer(),
                recent ?
                Icon(Icons.history_rounded, color: Colors.grey,) :
                userId != Constants.myUserId ?
                IconButton(
                  icon: Icon(
                    blocked ? Icons.block_rounded :
                    befriended ? Icons.auto_awesome :
                    !sentReq && !receivedReq ? Icons.person_add :
                    sentReq ? Icons.cancel_rounded :
                    Icons.watch_later_rounded,

                    color: blocked ? Colors.red :
                    befriended ? Colors.black :
                    !sentReq && !receivedReq ? Colors.orange :
                    sentReq ? Colors.redAccent :
                    Colors.grey,
                  ),
                  onPressed: (){
                    if(!befriended && !blocked){
                      if(!sentReq && !receivedReq){
                        DatabaseMethods(uid: Constants.myUserId).sendFriendRequest(userId);
                        showCenterFlash(alignment: Alignment.center, context: context, text: 'Requested');
                      }else if(sentReq){
                        DatabaseMethods(uid: Constants.myUserId).cancelFriendRequest(userId);
                        showCenterFlash(alignment: Alignment.center, context: context, text: 'Canceled');
                      }
                    }
                  },
                ) : SizedBox.shrink()
              ],
            ),
          ),
        );
  }

  Widget searchUserList(){
    return StreamBuilder(
        stream: usersStream,
        builder: (context, snapshot){
          if(snapshot.hasData){
            if(snapshot.data != null){
              return snapshot.data.hits.length as int > 0 ?
              ListView.builder(
                  itemCount: snapshot.data.hits.length as int,
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                    return searchUserTile(
                      snapshot.data.hits[index].objectID,
                      false
                    );
                  }) : noItems(icon: Icons.search_rounded, text: "search not found");
            }else{
              return SizedBox.shrink();
            }
          }else{
            return sectionLoadingIndicator();
          }
        });
  }

  Widget recentSearchList(){
    return recentSearch != null ?
    ListView.builder(
      itemCount: recentSearch.length,
      itemBuilder: (context, index){
        return searchUserTile(recentSearch[index], true);
      },
    ) : SizedBox.shrink();
  }

  @override
  void didUpdateWidget(covariant UsersList oldWidget) {
    // TODO: implement didUpdateWidget
    searchUsers(widget.searchText);
    super.didUpdateWidget(oldWidget);
  }


  @override
  void initState() {
    searchUsers(widget.searchText);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseMethods(uid: Constants.myUserId).getMyStream(),
      builder: (context, snapshot) {
        if(snapshot.hasData && snapshot.data.data() != null){
          friends = snapshot.data.data()["friends"];
          sentFdReq = snapshot.data.data()["sentFdReq"];
          receivedFdReq = snapshot.data.data()["receivedFdReq"];
          blockList = snapshot.data.data()["blockList"];
          recentSearch = snapshot.data.data()["reUserSearch"];
          return widget.searchText.isNotEmpty ?
          searchUserList() :
          recentSearchList();
        }else{
          return screenLoadingIndicator(context);
        }
      }
    );
  }
}
