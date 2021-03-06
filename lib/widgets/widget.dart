import 'dart:ui';

import 'package:SpidrApp/decorations/widgetDecorations.dart';
import 'package:SpidrApp/helper/authenticate.dart';
import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/services/auth.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/views/docViewScreen.dart';
import 'package:SpidrApp/views/mediaViewScreen.dart';
import 'package:SpidrApp/views/myProfilePage.dart';
import 'package:SpidrApp/views/userProfilePage.dart';
import 'package:SpidrApp/widgets/bottomSheetWidgets.dart';
import 'package:SpidrApp/widgets/dialogWidgets.dart';
import 'package:SpidrApp/widgets/mediaPageViews.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:flash/flash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:SpidrApp/views/mediaPreview.dart';
import "package:SpidrApp/helper/functions.dart";

// App Bar Widget
Widget appBarMain(BuildContext context){
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0.0,
  );
}

// Simple Text Widget
TextStyle simpleTextStyle(){
  return TextStyle(
      color: Colors.white,
      fontSize: 16
  );
}

void showCenterFlash({
  FlashPosition position,
  FlashStyle style,
  Alignment alignment,
  BuildContext context,
  String text
}) {
  showFlash(
    context: context,
    duration: Duration(seconds: 3),
    builder: (_, controller) {
      return Flash(
        controller: controller,
        backgroundColor: Colors.black87,
        borderRadius: BorderRadius.circular(8.0),
        borderColor: Colors.blue,
        position: position,
        style: style,
        alignment: alignment,
        enableDrag: false,
        onTap: () => controller.dismiss(),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: DefaultTextStyle(
            style: TextStyle(color: Colors.white),
            child: Text(text),
          ),
        ),
      );
    },
  );
}

Widget profileDisplay(String profileImg){
  return Container(
    decoration: shadowEffect(30),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: profileImg.startsWith('assets',0) ?
      Image.asset(profileImg, fit: BoxFit.cover) : Image.network(profileImg, fit: BoxFit.cover,),
    ),
  );
}

Widget miyuDisplay(List miyus, int index){
  return Container(
      decoration: shadowEffect(30),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Image.asset(miyus[index], fit: BoxFit.cover,)
      )
  );
}


Widget avatarImg(String profileImg, double size){
  return profileImg != null ?
  CircleAvatar(
    radius: size,
    backgroundImage: profileImg.startsWith('assets',0) ?
    AssetImage(profileImg) : NetworkImage(profileImg),
  ) : SizedBox.shrink();
}

Widget imgEditBtt(){
  return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
          color: Colors.orange,
          shape:BoxShape.circle
      ),
      child: Icon(
        Icons.edit,
        size: 16,
        color: Colors.white,
      )
  );
}

Widget shortLink(BuildContext context, String link){
  final TargetPlatform platform = Theme.of(context).platform;
  var linkIcon = platform == TargetPlatform.android ? Icons.link_rounded : CupertinoIcons.link;

  String siteName = extractSiteName(link);

  return GestureDetector(
      onTap: (){
        String url = extractUrl(link);
        openUrl(url);
      },
      child: Container(
        width: 110,
        padding: EdgeInsets.symmetric(horizontal: 13.5,vertical: 4.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color:Colors.black54,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(linkIcon, color: Colors.white,),
            SizedBox(width: 5,),
            Flexible(
              child: Text(siteName,
                  style: GoogleFonts.varelaRound(color: Colors.white, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis
              ),
            )
          ],
        ),
      )
  );
}

Widget linkIndicator({
  BuildContext context,
  bool displayLink = true,
  String link,
  double topPadding = 9,
}){


  return displayLink ? Padding(
    padding: EdgeInsets.only(top: topPadding, left: 9),
    child: Align(
      alignment: Alignment.topLeft,
      child: shortLink(context, link),
    ),
  ) : SizedBox.shrink();
}

Widget gifIndicator(){
  return Align(
    alignment: Alignment.topRight,
    child: Icon(Icons.gif_rounded,color: Colors.orange, size: 36),
  );
}

Widget sectionLoadingIndicator(){
  return Center(
    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),),
  );
}

Widget screenLoadingIndicator(BuildContext context){
  return Align(
    alignment: FractionalOffset.center,
    child: Container(
      width: 70.0,
      height: 70.0,
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: sectionLoadingIndicator(),
      ),
    ),
  );
}

Widget sizedLoadingIndicator({double size = 54, double strokeWidth = 3}){
  return SizedBox(
    height: size,
    width: size,
    child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)
    ),
  );
}

Widget timerIndicator({double height, double width, int timeElapsed, color, double strokeWidth, bgColor}){
  return SizedBox(
    height: height,
    width: width,
    child: CircularProgressIndicator(
      strokeWidth: strokeWidth,
      value: timeElapsed != null ? 1 - timeElapsed/Duration.secondsPerDay: 1,
      valueColor: AlwaysStoppedAnimation<Color>(color),
      backgroundColor: bgColor,
    ),
  );
}

Widget fileUploadingPreview({
  BuildContext context,
  String filePath,
  String fileName,
  bool video = false,
  bool audio = false,
  bool pdf = false,
  List gifs,
  String caption,
  String link,
  double div = 1.0,
  int numOfLines,
  bool displayGifs = false,
  bool displayLink = true
}){
  return Stack(
    children: [
      pdf ? DocDisplay(
        fileName:fileName,
        gifs: conGifWidgets(gifs),
        caption: caption,
        div: div,
        numOfLines: numOfLines,
        displayGifs: displayGifs,
        link: link,
      ) : video || audio ?
      VideoAudioFilePreview(
        filePath: filePath,
        audioName: audio ? fileName : null,
        fullScreen: false,
        play: false,
        gifs: conGifWidgets(gifs),
        caption: caption,
        div: div,
        numOfLines: numOfLines,
        displayGifs: displayGifs,
        link: link,
        displayLink: displayLink,
      ) : SizedBox.expand(
        child: ImageFilePreview(
          filePath: filePath,
          fullScreen: false,
          gifs: conGifWidgets(gifs),
          caption: caption,
          div: div,
          numOfLines: numOfLines,
          displayGifs: displayGifs,
          link: link,
          displayLink: displayLink,
        ),
      ),
      Container(
        color: Colors.black54,
        padding: const EdgeInsets.all(5.0),
        child: sectionLoadingIndicator(),
      )
    ],
  );
}

Widget mediaAndFilePreview({
  BuildContext context,
  String senderId,
  Map imgObj,
  Map fileObj,

  double div = 1.0,
  int numOfLines,
  bool displayGifs = false,
  bool displayLink = true,

  Alignment muteBttAlign = Alignment.bottomRight,
  bool play,
}){
  bool video = imgObj != null && videoChecker(imgObj["imgName"]);
  bool audio = fileObj != null && audioChecker(fileObj["fileName"]);
  bool pdf = fileObj != null && pdfChecker(fileObj["fileName"]);

  String mediaUrl = imgObj != null ? imgObj['imgUrl'] : fileObj != null ? fileObj['fileUrl'] : null;
  String mediaPath = imgObj != null ? imgObj['imgPath'] : fileObj != null ? fileObj['filePath'] : null;

  String audioName= audio ? fileObj['fileName'] : null;
  String pdfName = pdf ? fileObj['fileName'] : null;

  bool sticker = imgObj != null && imgObj["sticker"] != null && imgObj["sticker"];

  String caption = imgObj != null ? imgObj['caption'] : fileObj != null ? fileObj['caption'] : null;
  String link = imgObj != null ? imgObj['link'] : fileObj != null ? fileObj['link'] : null;

  List gifs = imgObj != null ? imgObj['gifs'] : fileObj != null ? fileObj["gifs"] : null;
  bool mature = imgObj != null && imgObj['mature'] != null && imgObj['mature'];
  return Stack(
    alignment: Alignment.center,
    children: [
      SizedBox.expand(
        child: AspectRatio(
            aspectRatio: 4/5,
            child: pdf ? mediaUrl != null ?
            DocDisplay(
              fileName:pdfName,
              gifs: conGifWidgets(gifs),
              caption: caption,
              div: div,
              numOfLines: numOfLines,
              displayGifs: displayGifs,
              link: link,
            ) : fileUploadingPreview(
              context: context,
              fileName: pdfName,
              pdf: true,
              gifs: gifs,
              caption: caption,
              div: div,
              numOfLines: numOfLines,
              displayGifs: displayGifs,
              link: link,
              displayLink: displayLink,
            ) : video || audio ? mediaUrl != null ?
            VideoAudioUrlPreview(
              fileURL:mediaUrl,
              play:(!mature || senderId == Constants.myUserId) && play,
              video:video,
              audioName:audioName,
              muteBttAlign: muteBttAlign,
              fullScreen: false,
              gifs: conGifWidgets(gifs),
              caption: caption,
              div: div,
              numOfLines: numOfLines,
              displayGifs: displayGifs,
              link: link,
              displayLink: displayLink,
            ) : fileUploadingPreview(
              filePath:mediaPath,
              fileName: audioName,
              video: video,
              audio: audio,
              gifs: gifs,
              caption: caption,
              div: div,
              numOfLines: numOfLines,
              displayGifs: displayGifs,
              link: link,
              displayLink: displayLink,
            ) : mediaUrl != null ?
            ImageUrlPreview(
              fileURL: mediaUrl,
              gifs: conGifWidgets(gifs),
              caption: caption,
              div: div,
              numOfLines: numOfLines,
              displayGifs: displayGifs,
              boxFit: sticker ? BoxFit.contain : BoxFit.cover,
              link: link,
              displayLink: displayLink,
            ) : fileUploadingPreview(
              filePath:mediaPath,
              gifs: gifs,
              caption: caption,
              div: div,
              numOfLines: numOfLines,
              displayGifs: displayGifs,
              link: link,
              displayLink: displayLink,
            )
        ),
      ),

      senderId != Constants.myUserId && mature ?
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
            child: Image.asset("assets/icon/nsfwIcon.png", scale: 3,)
        ),
      ) : SizedBox.shrink()

    ],
  );
}


Widget mediaAndFileDisplay({
  Map imgObj,
  Map fileObj,
  String mediaId,
  BuildContext context,
  String senderId,
  String sendBy,
  bool play,
  bool showInfo,
  bool story,
  bool anon,

  Alignment muteBttAlign = Alignment.bottomRight,

  int mediaIndex,
  List mediaGallery,

  AsyncSnapshot storySnapshot,
  int storyIndex,

  String groupChatId,
  String hashTag,

  double div = 1.0,
  int numOfLines,
  bool displayGifs = false,
  bool displayLink = true,
  bool toPageView = false,
}){
  String mediaUrl = imgObj != null ? imgObj['imgUrl'] : fileObj != null ? fileObj['fileUrl'] : null;

  return GestureDetector(
      onTap: (){
        if(mediaUrl != null){
          if(!toPageView && !showInfo && fileObj != null && pdfChecker(fileObj["fileName"])){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DocViewScreen(
                        fileUrl:mediaUrl,
                        fileName:fileObj["fileName"]
                    )
                )
            );
          }else{
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                  !toPageView ?
                  MediaViewScreen(
                    senderId: senderId,
                    groupId: groupChatId,
                    mediaId: mediaId,
                    mediaObj: imgObj != null ? imgObj : fileObj != null ? fileObj : null,
                    showInfo: showInfo,
                    story: story,
                    anon: anon,
                    mediaGallery: mediaGallery,
                    mediaIndex: mediaIndex,
                  ) : groupChatId != null ?
                  GroupChatMediaPageView(
                    groupId:groupChatId,
                    hashTag: hashTag,
                    anon:anon,
                    messageId:mediaId,
                  ) : StoryPageView(
                      storyIndex,
                      storySnapshot,
                      mediaIndex
                  )
                )
            );
          }
        }
      },
      child: mediaAndFilePreview(
        senderId: senderId,
        context:context,
        imgObj: imgObj,
        fileObj: fileObj,
        div:div,
        numOfLines:numOfLines,
        displayGifs:displayGifs,
        displayLink: displayLink,
        muteBttAlign: muteBttAlign,
        play:play,
      )
    );
}

Widget mediaCommentList({
  BuildContext context,
  String mediaId,
  bool notInForageIcon = false,
  double heightDiv = 0.15,
  bool anon
}){

  return StreamBuilder(
    stream: DatabaseMethods(uid: Constants.myUserId).getMyStream(),
    builder: (context, snapshot) {
      List blockList;
      if(snapshot.hasData && snapshot.data.data() != null){
        blockList = snapshot.data.data()["blockList"];
      }
      return SizedBox(
        child: StreamBuilder(
          stream: DatabaseMethods().getMediaComments(mediaId),
          builder: (context, snapshot){
            var shadows = [
              Shadow(
                  color: Colors.black54,
                  offset: Offset(1, 1.5),
                  blurRadius: 1
              ),
            ];

            Widget commentWidget(String comment){
              return Text(
                  comment,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: shadows
                  )
              );
            }

            return snapshot.hasData && snapshot.data != null && snapshot.data.docs.length > 0 ?
            Container(
                  height: MediaQuery.of(context).size.height * heightDiv,
                  width: MediaQuery.of(context).size.width * 0.55,
                  margin: EdgeInsets.only(left: 9, bottom: 4.5),
                  child: ListView.builder(
                      reverse: true,
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index){
                        String senderId = snapshot.data.docs[index].data()["senderId"];
                        String commentId = snapshot.data.docs[index].id;
                        String comment = snapshot.data.docs[index].data()["comment"];
                        return blockList == null || !blockList.contains(senderId) ?
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: userProfile(userId: senderId, size: 18, anon: anon),
                          title: anon == null || !anon ?
                          userName(userId: senderId, color: Colors.white, fontWeight: FontWeight.bold, shadows:shadows) :
                          !urlRegExp.hasMatch(comment) ?
                          commentWidget(comment) :
                          urlLink(text:comment),

                          subtitle: anon == null || !anon ?
                          !urlRegExp.hasMatch(comment) ?
                          commentWidget(comment) :
                          urlLink(text:comment) :
                          null,

                          trailing: senderId == Constants.myUserId ?
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.black, size: 13.5,),
                            onPressed: (){
                              DatabaseMethods().delMediaComment(mediaId, commentId);
                            },
                          ) : null,
                        ) : SizedBox.shrink();
                      }
                  ),
                ): SizedBox.shrink();
          },
        ),
      );
    }
  );
}

class MediaCommentComposer extends StatefulWidget {
  final String mediaId;
  final bool autoFocus;
  final fillColor;
  final bool disabled;
  MediaCommentComposer({this.mediaId, this.autoFocus, this.fillColor, this.disabled});
  @override
  _MediaCommentComposerState createState() => _MediaCommentComposerState();
}

class _MediaCommentComposerState extends State<MediaCommentComposer> {
  final formKey = GlobalKey<FormState>();
  bool validComment = true;
  TextEditingController commentEditingController = new TextEditingController();

  sendMediaComment(){
    if(formKey.currentState.validate()){
      String comment = commentEditingController.text;
      DatabaseMethods(uid: Constants.myUserId).addMediaComment(widget.mediaId, comment);
      commentEditingController.text = "";
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    commentEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width * 0.75,
        child: Row(
            children: [
              Flexible(
                child: Form(
                  key: formKey,
                  child: TextFormField(
                      autofocus: widget.autoFocus,
                      onChanged: (val){
                        setState(() {
                          validComment = val.length <= 100 && !emptyStrChecker(val);
                        });
                      },
                      validator: (val){
                        return emptyStrChecker(val) ? "try typing in something" :
                        val.length > 100 ? "sorry, comment > 100 characters" : null;
                      },
                      controller: commentEditingController,
                      style: TextStyle(color: Colors.orange),
                      decoration: msgInputDec(
                          hintText: "Comment",
                          hintColor: Colors.orange,
                          fillColor: widget.fillColor
                      )
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.send_rounded,
                  color: Colors.orange
                ),
                onPressed:(){
                  sendMediaComment();
                },
              )
            ],
          )
    );
  }
}

Widget mediaCaption(BuildContext context, String caption, double div, int numOfLines){
  return Center(
    child:Container(
      color: Colors.white54,
      width: MediaQuery.of(context).size.width/div,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
        child: Text(
          caption,
          textAlign: TextAlign.center,
          style: GoogleFonts.varelaRound(color: Colors.black, fontSize: 15/div, fontWeight: FontWeight.bold),
          maxLines: numOfLines,
          overflow: numOfLines != null ? TextOverflow.ellipsis : null,
        ),
      ),
    ),
  );
}

Widget mediaSendBtt({icon, labelColor, bool off, String text = "Send"}){
  return Container(
    decoration: BoxDecoration(
        color: off ? Colors.grey : Colors.orange,
        borderRadius: BorderRadius.circular(15),
    ),
    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
    child: RichText(
        text: TextSpan(
            children: [
              WidgetSpan(child: Icon(icon, size: 20, color: off ? Colors.white : labelColor,)),
              WidgetSpan(child: SizedBox(width: 5,)),
              TextSpan(
                text: text,
                style: TextStyle(color: off ? Colors.white : labelColor,fontWeight: FontWeight.bold),
              )
            ]
        )
    ),
  );
}

Widget iconText(icon, text){
  return Row(
    children: [
      Icon(icon),
      Text(text)
    ],
  );
}

Widget sectionLabel(String label, decColor, textColor){
  return Container(
      decoration: BoxDecoration(
          color: decColor,
          borderRadius: BorderRadius.circular(30)
      ),
      padding: EdgeInsets.symmetric(horizontal: 13.5, vertical: 13.5),
      margin: EdgeInsets.all(9.0),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: textColor),)
  );
}

Widget dateDivider(bool newDay, String date){
  return newDay ? Row(
      children: <Widget>[
        Expanded(
            child: Divider(color: Colors.transparent,)
        ),
        Text(date, style: TextStyle(color: Colors.grey)),
        Expanded(
            child: Divider(color: Colors.transparent)
        ),
      ]
  ) : SizedBox.shrink();
}

Widget urlLink({String text, textColor = Colors.white, linkColor = Colors.white, int maxLines, overflow}){
  return Linkify(
    maxLines: maxLines,
    overflow: overflow,
    onOpen: (link) {
      openUrl(link.url);
    },
    text: text,
    style: TextStyle(color: textColor),
    linkStyle: GoogleFonts.varelaRound(color: linkColor, decoration: TextDecoration.none, fontWeight: FontWeight.bold),
  );
}

Widget urlPreview({
  BuildContext context,
  String url,
  textColor = Colors.white,
  linkColor = Colors.white,
  bool simpleUrl = true,
  int maxLines,
  overflow
}) {
  return AnyLinkPreview(
    link: youTubeSURLRegExp.hasMatch(url) ?
    repYouTubeUrl(url) :
    url,

    displayDirection: UIDirection.UIDirectionHorizontal,
    showMultimedia: true,
    titleStyle: TextStyle(
      color: Colors.orange,
      fontWeight: FontWeight.bold,
    ),
    bodyTextOverflow: TextOverflow.ellipsis,
    bodyStyle: TextStyle(color: Colors.black, fontSize: 12),
    errorWidget: simpleUrl ?
    Container(
      height: 110,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          shortLink(context, url),
          // SimpleUrlPreview(
          //   url: url,
          //   titleStyle: TextStyle(color:Colors.orange, fontWeight: FontWeight.bold),
          //   descriptionStyle: TextStyle(
          //     color: Colors.black,
          //   ),
          //   siteNameStyle: TextStyle(
          //       color: Colors.black,
          //       fontWeight: FontWeight.bold
          //   ),
          //   bgColor: Colors.white,
          // ),
        ],
      ),
    ) : SizedBox.shrink(),
    errorImage: "https://google.com/",
    cache: Duration(days: 7),
    backgroundColor: Colors.white,
    borderRadius: 15,
  );
}



Widget urlPreviewWrapper({
  BuildContext context,
  String text,
  String url,
  textColor = Colors.white,
  linkColor = Colors.white,
  bool preview = true,
  bool simpleUrl = true,
  int maxLines,
  overflow
}) {
  // String url;
  // if(text != null && text.isNotEmpty){
  //   url = extractUrl(text);
  // }
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      urlLink(text:text, textColor: textColor, linkColor: linkColor, maxLines: maxLines, overflow:overflow),
      url.isNotEmpty ? Flexible(
        child: urlPreview(
            context:context,
            url:url,
            textColor:textColor,
            simpleUrl:simpleUrl
        ),
      ) : SizedBox.shrink()
    ],
  );
}

Widget borderedText(String text, color){
  return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
            color: color,
            width: 3.0
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
          textAlign: TextAlign.center
      )
  );
}

Widget noStory(){
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.symmetric(vertical: 5),
    decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30)
    ),
    child: RichText(
        text: TextSpan(
            children: [
              WidgetSpan(child: Icon(Icons.warning_rounded, color: Colors.white,)),
              TextSpan(
                  text: " Snippet is no longer available",
                  style: TextStyle(color: Colors.white
                  )
              )
            ]
        )
    ),
  );
}

Widget noItems({icon, text, mAxAlign = MainAxisAlignment.center, color = Colors.grey}){
  return Row(
    mainAxisAlignment: mAxAlign,
    children: [
      Icon(icon, color: color,),
      SizedBox(width: 5,),
      Text(text, style: TextStyle(color:color),),
    ],
  );
}

Widget tagTile({String all, String tag, borderColor, textColor}){
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      color: borderColor,
    ),
    padding: EdgeInsets.symmetric(horizontal: all != null ? 12 : 6, vertical: 2.5),
    margin: EdgeInsets.symmetric(horizontal: all != null ? 0 : 6),
    child: Center(
          child: Text(
            all != null ? all : !tag.startsWith("#") ? "#"+tag : tag,
            style: TextStyle(
                color: textColor,
                fontWeight: all != null ? FontWeight.bold : FontWeight.w600,
            ),
          )
      ),
  );
}

Widget hashTags({List tags, boxColor, borderColor, textColor}){
  return Container(
    height: 45,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: tags.length,
      itemBuilder: (context, index){
        return Padding(
          padding: const EdgeInsets.only(right: 9, bottom: 9),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color:boxColor,
                border: Border.all(
                    color: borderColor,
                    width: 2
                )
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 9),
              child: Center(child: Text("#"+tags[index], style: TextStyle(color: textColor),)),
            ),
          ),
        );
      },
    ),
  );
}

Widget notifIcon(int numOfNewMsg, bool group){
  return Positioned(
      height: 20,
      width: 20,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: !group ? Colors.orange : Colors.red,
            borderRadius: BorderRadius.circular(40)
        ),
        child: Text(numOfNewMsg < 100 ? "$numOfNewMsg": "...",
          style:TextStyle(
              color: !group ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold
          ),
        ),
      )
  );
}

Widget privateGroupSign(platform){
  return Center(
    child: Column(
      children: [
        Icon(platform == TargetPlatform.android ? Icons.lock_rounded : CupertinoIcons.lock),
        Text("private", style: TextStyle(color: Colors.red),)
      ],
    ),
  );
}

Widget groupStateIndicator(String groupState, bool anon, mAxAlign){
  return Row(
    mainAxisAlignment: mAxAlign,
    children: [
      Text(
          groupState,
          style: TextStyle(
            color:groupState == "public" ? Colors.green :
            groupState == "private" ? Colors.red :
            Colors.black,
          )
      ),
      SizedBox(width:2.5),
      anon != null && anon ?
      Image.asset("assets/icon/icons8-anonymous-mask-50.png", scale: 3.0) :
      SizedBox.shrink()
    ],
  );
}

Widget filePreview(BuildContext context, String assetImg, String fileName, fullScreen){
  return Container(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage(assetImg),
        fit: BoxFit.cover,
      ),
    ),
    child: Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.125),
        child: Text(
          fileName,
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: !fullScreen ? 12.5 : 15
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

Widget iconNum(icon, int number){
  return Container(
    decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30)
    ),
    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
    child: RichText(
        text: TextSpan(
            children: [
              WidgetSpan(child: Icon(icon, size: 16, color: Colors.white,)),
              WidgetSpan(child: SizedBox(width: 5,)),
              TextSpan(
                  text: "$number",
                  style: TextStyle(color: Colors.white)
              )
            ]
        )
    ),
  );
}

Widget iconContainer({icon, contColor, double horPad = 9, double verPad = 4.5}){
  return Container(
    decoration: BoxDecoration(
        color: contColor,
        borderRadius: BorderRadius.circular(30)
    ),
    padding: EdgeInsets.symmetric(horizontal: horPad, vertical: verPad),
    child: Icon(icon, size: 16, color: Colors.white,),
  );
}

Widget groupProfile({
  String groupId,
  double height=54,
  double width=54,
  bool oneDay,
  int timeElapsed,
  String profileImg,
  double avatarSize=24
}){
  if(oneDay && timeElapsed/Duration.secondsPerDay >= 1){
    DatabaseMethods(uid: Constants.myUserId).deleteGroupChat(groupId);
  }
  return Stack(
    alignment: Alignment.center,
    children: [
      oneDay ?
      Padding(
        padding: const EdgeInsets.all(1.0),
        child: timerIndicator(
            height:height,
            width:width,
            timeElapsed:timeElapsed,
            color:Colors.black,
            strokeWidth:2,
            bgColor:Colors.grey
        ),
      ) : SizedBox.shrink(),
      avatarImg(profileImg, avatarSize),
    ],
  );
}

Widget snippetBtt(BuildContext context, platform){
  return GestureDetector(
    onTap: (){
      openCameraBttSheet(context:context);
    },
    child: Padding(
      padding: const EdgeInsets.only(right:9.0),
      child: Icon(
            Icons.settings_input_antenna, color: Colors.orange,
          ),
    ),
  );
}


Widget myAvatar(){
  return StreamBuilder(
    stream: DatabaseMethods(uid: Constants.myUserId).getMyStream(),
    builder: (context, snapshot) {
      if(snapshot.hasData && snapshot.data.data() != null){
        bool uploading = snapshot.data.data()["numOfUploads"] != null && snapshot.data.data()["numOfUploads"] > 0;

        return GestureDetector(
          onTap:() async{
            // showGetStartedDialog(context);
            bool hopOff = await Navigator.push(context, MaterialPageRoute(
                builder: (context) => MyProfileScreen()
            ));

            if(hopOff != null && hopOff){
              DatabaseMethods(uid: Constants.myUserId).hopOffNotifSetUp();
              AuthMethods().signOut().then((res) {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(
                    builder: (context) => Authenticate()
                ));
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(4.5),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [circleShadow,],
                  ),
                    child: avatarImg(Constants.myProfileImg, 24)
                ),
                uploading ? sizedLoadingIndicator() : SizedBox.shrink()
              ],
            ),
          ),
        );
      }else{
        return Padding(
          padding: const EdgeInsets.all(4.5),
          child: CircleAvatar(radius: 22,),
        );
      }

    }
  );
}


Widget userName({String userId, bool anon, FontWeight fontWeight, double fontSize, color = Colors.black, shadows}){
  bool isMe = userId == Constants.myUserId;
  return !isMe ?
  StreamBuilder(
      stream: DatabaseMethods().userCollection.doc(userId).snapshots(),
      builder: (context, snapshot) {
        if(snapshot.hasData && snapshot.data.data() != null){
          return Text(anon == null || !anon ? snapshot.data.data()['name'] : "Anonymous",
              style: TextStyle(color: color, fontWeight: fontWeight, fontSize: fontSize, shadows: shadows)
          );
        }else{
          return SizedBox.shrink();
        }
      }
  ) : Text(
      "Me",
      style: TextStyle(color: color, fontWeight: fontWeight, fontSize:fontSize, shadows: shadows)
  );
}

Widget userProfile({String userId, bool anon, double size = 24, toProfile = true, bool blockAble = true}){
  return StreamBuilder(
      stream: DatabaseMethods().userCollection.doc(userId).snapshots(),
      builder: (context, snapshot) {
        if(snapshot.hasData && snapshot.data.data() != null){
          String profileImg = snapshot.data.data()["profileImg"];
          String username = snapshot.data.data()["name"];
          int imgIndex = snapshot.data.data()["anonImg"];
          String anonImg = userMIYUs[imgIndex];
          return toProfile ? GestureDetector(
              onTap: (){
                if(anon == null || !anon){
                  if(blockAble){
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => UserProfileScreen(
                          userId:userId,
                        )
                    ));
                  }else{
                    openUserProfileBttSheet(context, userId, username, profileImg);
                  }
                }
              },
              child: avatarImg(anon == null || !anon ? profileImg : anonImg, size)
          ) : avatarImg(anon == null || !anon ? profileImg : anonImg, size);
        }else{
          return SizedBox.shrink();
        }
      }
  );
}












