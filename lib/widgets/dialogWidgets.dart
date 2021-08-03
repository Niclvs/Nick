import 'package:SpidrApp/decorations/widgetDecorations.dart';
import 'package:SpidrApp/helper/functions.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/views/personalChatScreen.dart';
import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/widgets/profilePageWidgets.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Widget iconTextTitle({icon, text, color = Colors.black}){
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Icon(icon, color:color),
      SizedBox(width: 5,),
      Flexible(child: Text(text, style:TextStyle(fontWeight: FontWeight.bold, color:color)))
    ],
  );
}

class GetStartedDialog extends StatefulWidget {
  @override
  _GetStartedDialogState createState() => _GetStartedDialogState();
}

class _GetStartedDialogState extends State<GetStartedDialog> {

  TextEditingController tagController = new TextEditingController();

  List sugTags = [];
  Map selTags = {};

  List tags = [];
  bool loading = true;

  getSugTags(){
    DatabaseMethods().getSugTags(max:18).then((tags) {
      setState(() {
        sugTags = tags;
        loading = false;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getSugTags();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal:18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: Colors.white,
        child: Container(
          height: MediaQuery.of(context).size.height*0.7,
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(18, 27, 18, 0),
          child: Stack(
            clipBehavior: Clip.none,
            alignment:Alignment.topCenter,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    children: [
                      Text("Welcome! ${Constants.myName != null && Constants.myName != "null null" ? Constants.myName : ""}",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                      ),
                      SizedBox(height: 5,),
                      Text("Add 3-5 Spidr Tags to make better connections!",
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 12),
                          textAlign:TextAlign.center
                      ),
                      SizedBox(height: 5,),
                    ],
                  ),
                  Column(
                    children:[
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 18),
                                  decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(30)
                                  ),
                                  child: TextField(
                                    style: TextStyle(color: Colors.black),
                                    controller: tagController,
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.tag),
                                      border: InputBorder.none,
                                    ),
                                  ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.keyboard_arrow_down, color: Colors.orange),
                            onPressed: (){
                              if(tags.length < 5){
                                var tag = tagController.text as dynamic;
                                if(tag.isNotEmpty){
                                  if(tag.length <= 18){
                                    setState(() {tags = [tag] + tags;});
                                    tagController.text = "";
                                  }else{
                                    Fluttertoast.showToast(
                                      msg: "Sorry, tag length exceeds 18",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.SNACKBAR,
                                      timeInSecForIosWeb: 3,
                                    );
                                  }
                                }
                              }
                            },
                          )
                        ],
                      ),

                      tags.length > 0 ?
                      Container(
                        height: 45,
                        margin: EdgeInsets.symmetric(vertical:9),
                        child: ListView.builder(
                          itemCount: tags.length,
                          physics:BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index){
                            return Stack(
                              children:[
                                Container(
                                  margin: EdgeInsets.only(right: 9),
                                  padding: EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.white,
                                    border: Border.all(
                                        color:Colors.black,
                                        width: 2.0
                                    ),
                                  ),
                                  child:Center(
                                    child:Text(tags[index].startsWith("#") ? tags[index] : "#"+tags[index],
                                        style:TextStyle(color:Colors.black)
                                    )
                                  )
                                ),
                                Positioned(
                                  bottom: 9,
                                  right: -3,
                                  child: IconButton(
                                    icon: Icon(Icons.cancel_rounded, size: 18, color: Colors.black),
                                    onPressed: (){
                                      int sugIndex = selTags[tags[index]];
                                      if(sugIndex != null) sugTags.insert(sugIndex, tags[index]);
                                      tags.removeAt(index);

                                      setState(() {});
                                    }
                                  ),
                                ),
                              ]
                            );
                          },
                        ),
                      ) : SizedBox.shrink()
                    ]
                  ),

                  Expanded(
                    child: !loading ?
                    GridView.count(
                      physics: BouncingScrollPhysics(),
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      children: sugTags.map((tag) =>
                          TextButton(
                              child: Container(
                                padding: EdgeInsets.only(
                                  bottom: 5, // Space between underline and text
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text("#"+tag,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:13
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.check_circle,color: Colors.black, size: 13.5,)
                                  ],
                                ),
                              ),
                              style: ButtonStyle(
                                foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                              ),
                              onPressed: () {
                                if(tags.length < 5){
                                  selTags[tag] = sugTags.indexOf(tag);
                                  tags = [tag] + tags;
                                  sugTags.remove(tag);
                                  setState(() {});
                                }
                              }
                          )
                      ).toList(),
                    ) : sectionLoadingIndicator(),
                  ),

                  Column(
                    children: [
                      SizedBox(height: 5,),
                      GestureDetector(
                        onTap:(){
                          DatabaseMethods().userCollection
                              .doc(Constants.myUserId)
                              .update({"getStarted":false,});
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child: Text("skip",
                            style: TextStyle(
                                color:Colors.grey,
                                fontWeight: FontWeight.w600
                            )
                        ),
                      ),
                      GestureDetector(
                          onTap: (){
                            if(tags.isNotEmpty){
                              DatabaseMethods().userCollection
                                  .doc(Constants.myUserId)
                                  .update({"getStarted":false, "tags":tags});
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 9),
                            padding: EdgeInsets.symmetric(vertical: 13.5, horizontal: 18),
                            decoration: BoxDecoration(
                                color: tags.isNotEmpty ? Color(0xffFF914D) : Colors.grey,
                                borderRadius: BorderRadius.circular(30)
                            ),
                            child: Text("I'm Ready!",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600
                                )
                            ),
                          )
                      ),
                    ],
                  )
                ],
              ),
              Positioned(
                top:-54,
                child:  CircleAvatar(
                  radius: 27,
                  backgroundImage: AssetImage("assets/images/SpidrNet.png")
                )
              )
            ],
          ),
        )
    );
  }
}

showGetStartedDialog(BuildContext context) async{
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return GetStartedDialog();
      });
}

class ReplyBoxDialog extends StatefulWidget {
  final String groupId;
  final String hashTag;
  final bool anon;
  final String userId;
  final String text;
  final int sendTime;
  final Map imgMap;
  final Map fileMap;
  final List mediaGallery;
  final String messageId;
  final String ogMediaId;

  ReplyBoxDialog(
      this.groupId,
      this.hashTag,
      this.anon,
      this.userId,
      this.text,
      this.sendTime,
      this.imgMap,
      this.fileMap,
      this.mediaGallery,
      this.messageId,
      this.ogMediaId,
      );

  @override
  _ReplyBoxDialogState createState() => _ReplyBoxDialogState();
}

class _ReplyBoxDialogState extends State<ReplyBoxDialog> {
  TextEditingController replyEditingController = new TextEditingController();
  final formKey = GlobalKey<FormState>();

  replyMessage() async {
    if (formKey.currentState.validate()) {
      String replyMsg = replyEditingController.text;
      DateTime now = DateTime.now();

      Map<String, dynamic> replyMap = {
        'text': replyMsg,
        'sender': widget.anon == null || !widget.anon ? Constants.myName : "Anonymous",
        'senderId': Constants.myUserId,
        'sendTime': now.microsecondsSinceEpoch,
        'sendTo': widget.userId,
        'group': widget.groupId + '_' + widget.hashTag,
        'msgId': widget.messageId,
        'imgMap': null,
        'fileMap': null,
        'mediaGallery': null,
      };

      await DatabaseMethods(uid: Constants.myUserId,).createPersonalChat(
          userId: widget.userId,
          text: widget.text,
          sendTime: widget.sendTime,
          imgMap: widget.imgMap,
          fileMap: widget.fileMap,
          mediaGallery: widget.mediaGallery,
          myReply: replyMap,
          groupId: widget.groupId,
          hashTag: widget.hashTag,
          anon: widget.anon,
          messageId: widget.messageId,
          actionType: "REPLY_CHAT",
          ogMediaId: widget.ogMediaId,
      ).then((personalChatId){

        DatabaseMethods(uid: Constants.myUserId).updateConversationMessages(
          groupChatId: widget.groupId,
          messageId: widget.messageId,
          personalChatId: personalChatId,
          userId: widget.userId,
          username: widget.anon == null || !widget.anon ?
          Constants.myName :
          "Anonymous",
          actionType: "ADD_REPLY",
        );

        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => PersonalChatScreen(
              personalChatId:personalChatId,
              contactId:widget.userId,
              openByOther: false,
              anon: widget.anon,
              friend: false,
            ))
        );
      });

      replyEditingController.text = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30))
          ),
          title: iconTextTitle(icon:Icons.maps_ugc, text:"Private Chat"),
          content: Form(
            key: formKey,
            child: TextFormField(
                autofocus: true,
                validator: (val){
                  return emptyStrChecker(val) ? "Hey! type something in" : null;
                },
                controller: replyEditingController,
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
          ),
          actions: [
            TextButton(
                onPressed:(){
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: Text("CANCEL")
            ),
            TextButton(
                onPressed:() {
                  replyMessage();
                },
                child: Text("SEND")
            ),
          ],
    );
  }
}

showReplyBox({
  BuildContext context,
    String groupId,
    String hashTag,
    bool anon,
    String userId,
    String text,
    int sendTime,
    Map imgMap,
    Map fileMap,
    List mediaGallery,
    String messageId,
    String ogMediaId,
}){
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return ReplyBoxDialog(
          groupId,
          hashTag,
          anon,
          userId,
          text,
          sendTime,
          imgMap,
          fileMap,
          mediaGallery,
          messageId,
          ogMediaId,
        );
      });
}


showMediaCommentDialog(BuildContext context, String mediaId, bool anon){
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(12, 18, 12, 24),
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30))
          ),
          content: Container(
            height: MediaQuery.of(context).size.height*0.3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: mediaCommentList(context:context, mediaId:mediaId, anon:anon)),
                MediaCommentComposer(mediaId:mediaId, autoFocus:true)
              ],
            ),
          )
        );
      }
  );
}

class AddTagOnCreateDialog extends StatefulWidget {
  @override
  _AddTagOnCreateDialogState createState() => _AddTagOnCreateDialogState();
}

class _AddTagOnCreateDialogState extends State<AddTagOnCreateDialog> {
  List tags = [];
  TextEditingController tagController = new TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool noTag = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30))
      ),
      titlePadding: EdgeInsets.fromLTRB(24, 27, 0, 14),
      contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      title: Text(!noTag ? "Add Tags" : "Sorry, one extra tag is required",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: !noTag ? Colors.black : Colors.redAccent,
            fontSize: !noTag ? 18 : 14,
          )
      ),
      content: Container(
          height: MediaQuery.of(context).size.height * 0.2,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text('add relevant tags to enhance your public circle',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)
                  )
              ),
              SizedBox(height: 13.5),
              Container(
                  height: 45,
                  child: ProfileTagList(
                    editable: true,
                    tags: tags,
                    tagController: tagController,
                    formKey: formKey,
                    tagNum: Constants.maxTags,
                  )
              ),
            ],
          )
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("CANCEL",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              )
          ),
        ),
        TextButton(
          onPressed: () {
            if (tags.isEmpty) setState(() {noTag = true;});
            else Navigator.pop(context, tags);
          },
          child: Text("OK",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              )
          ),
        ),
      ],
    );
  }
}

class ReportContentDialog extends StatefulWidget {
  @override
  _ReportContentDialogState createState() => _ReportContentDialogState();
}

class _ReportContentDialogState extends State<ReportContentDialog> {
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final TargetPlatform platform = Theme.of(context).platform;

    return AlertDialog(
      title: iconTextTitle(
          icon:platform == TargetPlatform.android ?
          Icons.flag_rounded : CupertinoIcons.flag_fill,
          text: "Report Content"
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30))
      ),
      contentPadding: EdgeInsets.all(12),
      content: Container(
        height: MediaQuery.of(context).size.height*0.5,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: reportReasons.map((m) {
            int index = reportReasons.indexOf(m);
            return CheckboxListTile(
              title: Text(m),
              value: selectedIndex == index,
              onChanged:(bool val){
                setState(() {
                  selectedIndex = val ? index : -1;
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed:(){
            Navigator.pop(context);
          },
          child: Text("CANCEL",
            style:TextStyle(color:Colors.redAccent, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed:(){
            if(selectedIndex != -1)
              Navigator.pop(context, reportReasons[selectedIndex]);
          },
          child: Text("REPORT",
            style:TextStyle(
                color:selectedIndex != -1 ? Colors.black : Colors.grey,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
      ],
    );
  }
}

class ShareMediaGalleryDialog extends StatefulWidget {
  final List mediaGallery;
  ShareMediaGalleryDialog(this.mediaGallery);

  @override
  _ShareMediaGalleryDialogState createState() =>
      _ShareMediaGalleryDialogState();
}

class _ShareMediaGalleryDialogState extends State<ShareMediaGalleryDialog> {
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final TargetPlatform platform = Theme.of(context).platform;

    return AlertDialog(
      title: iconTextTitle(
          icon: platform == TargetPlatform.android ?
          Icons.share :
          CupertinoIcons.share,
          text:"Share Media"
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30))
      ),
      titlePadding: EdgeInsets.all(18),
      contentPadding: EdgeInsets.all(12),
      content: Container(
        height: MediaQuery.of(context).size.height*0.25,
        width: MediaQuery.of(context).size.width,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: widget.mediaGallery.map((m) {
            int index = widget.mediaGallery.indexOf(m);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width*0.3, // custom width
                    height: MediaQuery.of(context).size.height*0.2,
                    decoration: shadowEffect(30),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: mediaAndFileDisplay(
                          context:context,
                          imgObj:m,
                          div:3,
                          numOfLines: 1,
                          play: false,
                          showInfo: false,
                        )),
                  ),
                  SizedBox(
                    width: 25,
                    height: 25,
                    child: Checkbox(
                      value: selectedIndex == index,
                      onChanged: (val) {
                        if (val) {
                          setState(() {
                            selectedIndex = index;
                          });
                        } else {
                          setState(() {
                            selectedIndex = -1;
                          });
                        }
                      },
                    ),
                  )
                ],
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("CANCEL",
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed: () {
            if (selectedIndex != -1)
              Navigator.pop(context, widget.mediaGallery[selectedIndex]);
          },
          child: Text("OK",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

showBanMemberDialog(BuildContext context, String hashTag, String userId, bool anon)async{
  return await showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30))
          ),
          // contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          title: iconTextTitle(icon: Icons.do_disturb_on_rounded, text:"Ban User", color:Colors.red),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                textAlign: TextAlign.center,
                  text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Column(
                            children: [
                              userProfile(userId:userId, anon:anon, size: 18),
                              userName(userId:userId, anon: anon, fontSize: 14, fontWeight:FontWeight.w600)
                            ],
                          ),
                        ),
                        TextSpan(
                          text: " will be banned from ",
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: hashTag,
                          style: TextStyle(color: Colors.black, fontWeight:FontWeight.w600),
                        )
                      ]
                  )
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed:(){
                  Navigator.pop(context, "LEAVE_GROUP");
                },
                child: Text("Just Once",style: TextStyle(color: Colors.orange))
            ),
            TextButton(
                onPressed:(){
                  Navigator.pop(context, "BAN_USER");
                },
                child: Text("Permanently",style: TextStyle(color: Colors.black))
            )
          ],
        );
      }
  );
}

showAlertDialog(String text, BuildContext context){
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30))
          ),
          title: Text("Sorry", style: TextStyle(color: Colors.orange)),
          content: Text(text),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: Text("OK", style: TextStyle(color: Colors.blue)))
          ],
        );
      });
}

showLogOutDialog(BuildContext context) async {
  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30))
          ),
          title: iconTextTitle(icon:Icons.logout, text: "Hop Off"),
          content: RichText(
            text: TextSpan(
              text: 'Are you sure you want to hop off?',
              style: TextStyle(fontWeight: FontWeight.w600, color:Colors.black),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text("CANCEL",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('SURE'),
            ),
          ],
        );
      }
  );
}

showClearSearchDialog(BuildContext context) async {
  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30))
          ),
          title: iconTextTitle(icon:Icons.history_rounded, text: "Clear Search History"),
          content: RichText(
            text: TextSpan(
              text: 'Are you sure you want to clear your search history?',
              style: TextStyle(fontWeight: FontWeight.w600, color:Colors.black),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text("CANCEL",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('SURE'),
            ),
          ],
        );
      }
  );
}

showRepliedUsersDialog(
    List replies,
    String messageId,
    String groupId,
    BuildContext context,
    bool anon
    ){
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30))
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: replies.length,
                itemBuilder: (context, index){
                  String userId = replies[index]["userId"];
                  String personalChatId = replies[index]["personalChatId"];
                  String username = replies[index]["username"];
                  bool opened = replies[index]["open"];
                  return !opened ?
                  Card(
                    elevation: 0.0,
                    margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    child: Container(
                      child: GestureDetector(
                        onTap: () async{
                          await DatabaseMethods(uid: Constants.myUserId).updateConversationMessages(
                              groupChatId:groupId,
                              messageId:messageId,
                              personalChatId:personalChatId,
                              userId:userId,
                              actionType:"OPEN_REPLY"
                          );
                          Navigator.pushReplacement(context, MaterialPageRoute(
                              builder: (context) => PersonalChatScreen(
                                personalChatId:personalChatId,
                                contactId:userId,
                                openByOther:true,
                                friend:false,
                                anon: anon,
                              )
                          )
                          );
                        },
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          title: Text("From " + username),
                          trailing: Icon(Icons.keyboard_arrow_right, size: 30.0,),
                        ),
                      ),
                    ),
                  ) : SizedBox.shrink();
                }
            ),
          ),
        );
      });
}

showJoinGroupAlertDialog(BuildContext context, String groupState, String groupId, String hashTag) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Hey!", style: TextStyle(color: Colors.orange)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
          content: Text(groupState == 'public' || groupState == 'invisible'
              ? "This group you are trying to join has reached its full capacity. Do you want to be on the waitlist and spectate?"
              : "This group you are requesting to join has reached its full capacity. Do you want to be on the waitlist?"),
          actions: [
            FlatButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: Text("NO", style: TextStyle(color: Colors.red))),
            FlatButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  DatabaseMethods(uid: Constants.myUserId).putOnWaitList(
                      groupId,
                      Constants.myName,
                      Constants.myUserId,
                      Constants.myEmail,
                      null
                  );
                },
                child: Text("YES", style: TextStyle(color: Colors.green))),
          ],
        );
      });
}

class SelectAnonImgDialog extends StatefulWidget {
  final int imgIndex;
  SelectAnonImgDialog(this.imgIndex);

  @override
  _SelectAnonImgDialogState createState() => _SelectAnonImgDialogState();
}

class _SelectAnonImgDialogState extends State<SelectAnonImgDialog> {
  PageController controller;
  int imgIndex;

  @override
  void initState() {
    // TODO: implement initState
    imgIndex = widget.imgIndex;
    controller = PageController(
        initialPage: imgIndex, keepPage: false, viewportFraction: 0.5);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, imgIndex);
        return true;
      },
      child: Dialog(
          insetPadding: EdgeInsets.all(15),
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30))),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    avatarImg(userMIYUs[imgIndex], 36),
                    Positioned(
                      top: 81,
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(blurRadius: 2.5, color: Colors.white)
                            ],
                          ),
                          child: Image.asset(
                              "assets/icon/icons8-anonymous-mask-50.png",
                              scale: 2.25
                          )
                      ),
                    )
                  ],
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: miyuList(),
                )
              ],
            ),
          )
      ),
    );
  }

  Widget miyuList() {
    return PageView.builder(
        itemCount: userMIYUs.length,
        controller: controller,
        onPageChanged: (val) {
          setState(() {
            imgIndex = val;
          });
        },
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              double value = 1.0;
              if (controller.position.haveDimensions) {
                value = controller.page - index;
                value = (1 - (value.abs() * .5)).clamp(0.0, 1.0);
              }
              return Center(
                child: SizedBox(
                  height: Curves.easeOut.transform(value) * 150,
                  width: Curves.easeOut.transform(value) * 300,
                  child: child,
                ),
              );
            },
            child: miyuDisplay(userMIYUs, index),
          );
        });
  }
}

class DeleteGroupDialog extends StatefulWidget {
  final String groupId;
  final String hashTag;

  DeleteGroupDialog(this.hashTag, this.groupId);

  @override
  _DeleteGroupDialogState createState() => _DeleteGroupDialogState();
}

class _DeleteGroupDialogState extends State<DeleteGroupDialog> {
  final formKey = GlobalKey<FormState>();
  TextEditingController hashTagConfirmController = new TextEditingController();
  bool matchTag = false;

  deleteGroup() {
    if (formKey.currentState.validate()) {
      DatabaseMethods(uid: Constants.myUserId).deleteGroupChat(widget.groupId);
      Navigator.pop(context, true);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    hashTagConfirmController.addListener(() {
      if (hashTagConfirmController.text == widget.hashTag) {
        matchTag = true;
      } else {
        matchTag = false;
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    hashTagConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        titlePadding: EdgeInsets.all(18),
        contentPadding: EdgeInsets.all(12),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30))
        ),
        title: iconTextTitle(icon:Icons.timer, text: "Time's Up", color:Colors.red),
        content: Container(
          height: MediaQuery.of(context).size.height*0.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  text: 'Confirm that it is time delete this circle by typing its hashtag: ',
                  style: TextStyle(fontWeight: FontWeight.bold, color:Colors.grey),
                  children: <TextSpan>[
                    TextSpan(text: widget.hashTag, style: TextStyle(fontWeight: FontWeight.bold, color:Colors.black)),
                  ],
                ),
            ),
            SizedBox(height: 10),
            Flexible(
              child: Form(
                key: formKey,
                child: TextFormField(
                    autofocus: true,
                    textCapitalization: TextCapitalization.characters,
                    validator: (val) {
                      return val != widget.hashTag ? "Incorrect hashtag" : null;
                    },
                    controller: hashTagConfirmController,
                    style: TextStyle(color: Colors.black),
                    decoration: msgInputDec(
                        hintText: widget.hashTag,
                        hintColor: Colors.grey,
                        fillColor: Colors.white
                    )
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: Text("CANCEL",
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.black,
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
          ),
          onPressed: matchTag ? () => deleteGroup() : null,
          child: const Text('DELETE'),
        ),
      ],
    );
  }
}

List<Widget> recTagButtons(TextEditingController editor, List tags) {
  return tags.map((tag) =>
    TextButton(
        child: Text("#"+tag,),
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
        ),
        onPressed: () { editor.text = tag; }
    )
  ).toList();
}

showTextBoxDialog({
  @required BuildContext context,
  @required String text,
  @required TextEditingController textEditingController,
  @required String errorText,
  Function editQuote,
  Function editTag,
  @required formKey,
  int index
}) async {
  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
          title: Text(text),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: formKey,
                child: TextFormField(
                  autofocus: true,
                  validator: (val) {
                    if (emptyStrChecker(val))
                      return errorText;
                    else if ((text == "About Me" || text == "About Circle") && val.length > 100)
                      return "Content > 100 characters";
                    else if (text == "Tag" && val.length > 18)
                      return "Tag > 18 characters";
                    return null;
                  },
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  controller: textEditingController,
                ),
              ),
              text == "Tag" ? FutureBuilder(
                future: DatabaseMethods().getSugTags(),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    return Flexible(
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        child:Wrap(
                            children: recTagButtons(textEditingController, snapshot.data)
                        ),
                      ),
                    );
                  }else{
                    return SizedBox.shrink();
                  }
                }
              ) : SizedBox.shrink()
            ]
          ),
          actions: [
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("CANCEL",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                )
            ),
            FlatButton(
                onPressed: () {
                  if (editQuote != null)
                    editQuote(textEditingController.text);
                  else if (editTag != null)
                    editTag(textEditingController.text, index);
                  else
                    Navigator.pop(context, textEditingController.text);
                },
                child: Text("SAVE",
                  style:TextStyle(color:Colors.black, fontWeight: FontWeight.bold),
                )
            )
          ],
        );
      });
}

class CreateHashTagDialog extends StatefulWidget {
  final String selTag;
  CreateHashTagDialog(this.selTag);
  @override
  _CreateHashTagDialogState createState() => _CreateHashTagDialogState();
}

class _CreateHashTagDialogState extends State<CreateHashTagDialog> {
  final formKey = GlobalKey<FormState>();
  TextEditingController hashTagController = new TextEditingController();
  bool validHashTag = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
      title: Text(widget.selTag),
      content: Form(
        key: formKey,
        child: TextFormField(
          autofocus: true,
          onChanged: (val){
            setState(() {
              validHashTag = val.length <= 18 && !emptyStrChecker(val);
            });
          },
          validator: (val) {
            if (emptyStrChecker(val))
              return "Please enter a hashTag";
            else if (val.length > 18)
              return "Maximum length 18";
            return null;
          },
          style: TextStyle(color: Colors.black, fontSize: 14),
          controller: hashTagController,
          decoration: hashTagFromDec(hashTagController.text.length, validHashTag),
        ),
      ),
      actions: [
        FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("CANCEL",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            )
        ),
        FlatButton(
            onPressed: () {
              if(formKey.currentState.validate())
                Navigator.pop(context, hashTagController.text);
            },
            child: Text("CREATE",
              style:TextStyle(color:Colors.black, fontWeight: FontWeight.bold),
            )
        )
      ],
    );
  }
}

showSpidrIdBoxDialog(
    BuildContext context,
    DocumentReference userDocRef,
    spidrIdKey,
    TextEditingController spidrIdEditingController,
    ) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            backgroundColor: Colors.white,
            child: Container(
              height: 250,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  SizedBox(height: 24),
                  Text("Update your Spidr ID",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10, right: 15, left: 15),
                      child: Form(
                        key: spidrIdKey,
                        child: TextFormField(
                          validator: (val) {
                            return val.length > 18 ? "Max length 18" :
                            emptyStrChecker(val) ? "Sorry, Spidr ID can not be empty" :
                            null;
                          },
                          controller: spidrIdEditingController,
                          style: TextStyle(color: Colors.black),
                          cursorColor: Colors.orangeAccent,
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: "Enter a Username",
                            labelText: "Spidr ID",
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.orange),
                            ),
                          ),
                        ),
                      )
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextButton(
                          onPressed: () {
                            if(spidrIdKey.currentState.validate()){
                              String name = spidrIdEditingController.text;
                              Constants.myName = name;
                              userDocRef.update({'name':name});
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          },
                          child: Text("Continue")
                      ),
                    ],
                  ),
                ],
              ),
            )
        );
      });
}

