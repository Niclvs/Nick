import 'dart:io';
import 'package:SpidrApp/decorations/widgetDecorations.dart';
import 'package:SpidrApp/helper/functions.dart';
import 'package:SpidrApp/services/newFileUpload.dart';
import 'package:SpidrApp/views/docViewScreen.dart';
import 'package:SpidrApp/widgets/mediaGalleryWidgets.dart';
import 'package:SpidrApp/widgets/mediaAndFilePicker.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mediaPreview.dart';
import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/widgets/dynamicStackItem.dart';
import 'package:SpidrApp/views/sendSnippetDialog.dart';


class PreviewScreen extends StatefulWidget {
  final String filePath;
  final bool vidOrAud;
  final bool tagPublic;
  final String personalChatId;
  final bool friend;
  final String contactId;
  final String groupChatId;

  final File file;
  final String audioName;
  final String fileName;
  final bool edit;
  final String caption;
  final String link;
  final List<DynamicStackItem> gifs;

  final List<SelectedFile> selMedia;
  final bool mature;

  PreviewScreen({
    this.filePath,
    this.vidOrAud,
    this.tagPublic,
    this.personalChatId,
    this.friend,
    this.contactId,
    this.groupChatId,

    this.file,
    this.audioName,
    this.fileName,
    this.edit = false,
    this.caption,
    this.link,
    this.gifs,

    this.selMedia,
    this.mature = false,
  });

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen>
    with WidgetsBindingObserver {

  File imgFile;
  final formKey = GlobalKey<FormState>();
  TextEditingController captionEditingController = new TextEditingController();
  TextEditingController linkEditingController = new TextEditingController();

  // int numOfGroups = 0;
  // int numOfFriends = 0;

  bool addCaption = false;
  bool attachLink = false;

  bool validCaption = false;
  bool validLink = false;

  List<DynamicStackItem> gifyStickers = [];
  List mediaList = [];

  bool loading = false;
  bool mature = false;
  bool openKeyBoard = false;

  sendMediaToChats() {
    if(widget.selMedia != null){
      mediaListSendToChats();
    }else{
      mediaSendToChat();
    }
    Navigator.of(context).pop();
  }

  tagPublic() async{
    bool sent;
    // if(numOfFriends > 0 || numOfGroups > 0){
    //   sent = await showDialog(
    //       context: context,
    //       builder: (BuildContext context){
    //         return SendMediaDialog(
    //           mediaList: widget.selMedia != null ? mediaList : null,
    //           // mediaList: widget.selMedia != null ? conMediaList(widget.selMedia) : null,
    //           mediaPath: widget.file != null ? widget.file.path : widget.filePath != null ? widget.filePath : null,
    //           caption: captionEditingController.text,
    //           gifs: conGifMap(gifyStickers),
    //           video: widget.vidOrAud,
    //         );
    //       }
    //   );
    // }else{
      sent = await showDialog(
          context: context,
          builder: (BuildContext context){
            return SendSnippetDialog(
              mediaList: widget.selMedia != null ? mediaList : null,
              mediaPath: widget.file != null ? widget.file.path : widget.filePath != null ? widget.filePath : null,
              caption: captionEditingController.text,
              link: linkEditingController.text,
              gifs: conGifMap(gifyStickers),
              video: widget.vidOrAud,
              mature: mature,
            );
          }
      );
    // }

    if(sent != null && sent) Navigator.of(context).pop();
    return sent != null && sent;
  }

  // getUserInfo() async{
  //   QuerySnapshot groupQS = await DatabaseMethods().userCollection.doc(Constants.myUserId).collection('groups').get();
  //   numOfGroups = groupQS.docs.length;
  //   QuerySnapshot friendQS = await DatabaseMethods().userCollection.doc(Constants.myUserId).collection('friends').get();
  //   numOfFriends = friendQS.docs.length;
  // }

  @override
  Widget build(BuildContext context) {
    final TargetPlatform platform = Theme.of(context).platform;

    return WillPopScope(
      onWillPop: () async{
        if(widget.edit != null && widget.edit){
          String caption = validCaption ? captionEditingController.text : widget.caption;
          String link = validLink ? linkEditingController.text : widget.link;
          Navigator.pop(context, [caption, link, gifyStickers, mature]);
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: widget.audioName == null && widget.fileName == null,
        appBar: AppBar(
          leading: BackButton(
              color: widget.audioName == null && widget.fileName == null ? Colors.white : Colors.black
          ),
          backgroundColor: widget.audioName == null && widget.fileName == null ? Colors.transparent : Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                child: widget.fileName == null ?
                SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: widget.selMedia != null ?
                    MediaGalleryTile(
                      story: true,
                      startIndex: 0,
                      mediaGallery: mediaList,
                      height: MediaQuery.of(context).size.height,
                      autoPlay: false,
                    ) : widget.vidOrAud ?
                    VideoAudioFilePreview(
                        filePath: widget.filePath,
                        videoFile: widget.file,
                        audioName: widget.audioName,
                        fullScreen:true,
                        play: true,
                    ) : ImageFilePreview(
                      filePath: widget.filePath,
                      imgFile: widget.file,
                      fullScreen: true,
                    )
                ) : GestureDetector(
                    onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DocViewScreen(
                                  file:widget.file,
                                  fileName:widget.fileName
                              )
                          )
                      );
                    },
                    child: DocDisplay(fileName: widget.fileName, fullScreen: true)
                )
              ),

              widget.selMedia == null ?
              Stack(children: gifyStickers) :
              SizedBox.shrink(),

              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      addCaption ?
                      TextFormField(
                        autofocus: true,
                        minLines: 1,
                        maxLines: 3,
                        onChanged: (val){
                          setState(() {
                            validCaption = val.length <= 300 && !emptyStrChecker(val);
                          });
                        },
                        validator: (val){
                          return emptyStrChecker(val) ? "try typing in something" :
                          val.length > 300 ? "sorry, caption > 300 characters" : null;
                        },
                        controller: captionEditingController,
                        style: TextStyle(color: Colors.black, fontSize: 18,),
                        decoration: previewInputDec(
                            hintText:"ADD A CAPTION",
                            valid:validCaption,
                            textEtController:captionEditingController,
                            maxLength:300,
                            icon:Icons.text_fields_rounded,
                            fillColor:Colors.white54,
                            fontColor:Colors.black,
                            outlineColor:Colors.orange,
                            borderSide:BorderSide.none
                        ),
                      ) : SizedBox.shrink(),

                      attachLink ?
                      TextFormField(
                        autofocus: true,
                        minLines: 1,
                        maxLines: 1,
                        onChanged: (val){
                          setState(() {
                            validLink = urlRegExp.hasMatch(val);
                          });
                        },
                        validator: (val){
                          return !urlRegExp.hasMatch(val) ? "invalid url" : null;
                        },
                        controller: linkEditingController,
                        style: TextStyle(color: Colors.white, fontSize: 18,),
                        decoration: previewInputDec(
                            hintText:"ATTACH A LINK",
                            valid:validLink,
                            textEtController: linkEditingController,
                            icon:platform == TargetPlatform.android ? Icons.link_rounded : CupertinoIcons.link,
                            fillColor:Colors.black54,
                            fontColor:Colors.white,
                            outlineColor:Colors.orange,
                            borderSide:BorderSide.none
                        ),
                      ) : SizedBox.shrink(),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 13.5, bottom: 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    widget.tagPublic ?
                    Container(
                      width: 90,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.timer, color: Colors.white, size: 36,),
                          SizedBox(width: 5),
                          Text(
                            '24 hrs',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                    ) : SizedBox.shrink(),

                    widget.selMedia == null && widget.audioName == null && widget.fileName == null ?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Switch(
                          value: mature,
                          onChanged: (val){
                            setState(() {mature=val;});
                          },
                          activeTrackColor: Colors.orangeAccent,
                          activeColor: Colors.orange,
                        ),
                        Text(
                          "sensitive content?",
                          style: GoogleFonts.varelaRound(
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ) : SizedBox.shrink(),
                  ],
                ),
              ),
                // loading ?
                // screenLoadingIndicator(context) :
                // SizedBox.shrink(),
              ],
            )
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            !openKeyBoard && widget.selMedia == null ?
            SizedBox(
              height: 36,
              width: 36,
              child: FloatingActionButton(
                heroTag: 'cap',
                backgroundColor: Colors.orange,
                child: Icon(Icons.text_fields_rounded, size:27,color: Colors.white),
                onPressed: (){
                  setState(() {
                    addCaption = !addCaption;
                  });
                },
              ),
            ) : SizedBox.shrink(),

            SizedBox(height: widget.selMedia == null ? 10 : 0),

            !openKeyBoard && widget.selMedia == null ?
            SizedBox(
              height: 36,
              width: 36,
              child: FloatingActionButton(
                heroTag: 'gif',
                backgroundColor: Colors.orange,
                child: Icon(Icons.gif_rounded, size:36,color: Colors.white),
                onPressed: () async{
                  GiphyGif gif = await GiphyGet.getGif(
                      context: context,
                      apiKey: Constants.giphyAPIKey,
                      tabColor: Colors.orange
                  );
                  if(gif != null){
                    if(gif.images.original.webp != null){
                      setState(() {
                        gifyStickers.add(DynamicStackItem(gif.images.original.webp));
                      });
                    }else{
                      Fluttertoast.showToast(
                          msg: "Sorry, this gif is corrupted",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.SNACKBAR,
                          timeInSecForIosWeb: 3,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 14.0
                      );
                    }
                  }
                },
              ),
            ) : SizedBox.shrink(),

            SizedBox(height:widget.selMedia == null ?  10 : 0),

            !openKeyBoard && widget.selMedia == null ?
            SizedBox(
              height: 36,
              width: 36,
              child: FloatingActionButton(
                heroTag: 'link',
                backgroundColor: Colors.orange,
                child: Icon(
                    platform == TargetPlatform.android ? Icons.link_rounded : CupertinoIcons.link,
                    size:27,
                    color: Colors.white
                ),
                onPressed: (){
                  setState(() {
                    attachLink = !attachLink;
                  });
                },
              ),
            ) : SizedBox.shrink(),

            SizedBox(height: widget.selMedia == null ? 10 : 0),

            !widget.edit ?
            GestureDetector(
              onTap: () async{
                if(formKey.currentState.validate() && !loading){
                  setState(() {
                    loading = true;
                  });
                  if(widget.tagPublic){
                    bool sent = await tagPublic();
                    if(sent){
                      Navigator.of(context).pop();
                    }
                  } else{
                    await sendMediaToChats();
                    Navigator.of(context).pop();
                  }

                  setState(() {
                    loading = false;
                  });
                }
              },
              child: mediaSendBtt(
                  icon:widget.tagPublic ? Icons.settings_input_antenna_rounded : Icons.send_rounded,
                  labelColor:Colors.white,
                  off:false,
                  text: widget.tagPublic ? "Broadcast" : "Send"
              ),
            ) : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeMetrics() {
    // TODO: implement didChangeMetrics
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    setState(() {
      openKeyBoard = bottomInset > 0.0;
    });
    super.didChangeMetrics();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if(widget.selMedia != null)
      mediaList = conMediaList(widget.selMedia);

    if(widget.filePath != null)
      imgFile = new File(widget.filePath);

    if(widget.edit != null && widget.edit){
      if(widget.caption.isNotEmpty){
        captionEditingController.text = widget.caption;
        addCaption = true;
        validCaption = widget.caption.length <= 300 && !emptyStrChecker(widget.caption);
      }
      if(widget.link.isNotEmpty){
        linkEditingController.text = widget.link;
        attachLink = true;
        validLink = urlRegExp.hasMatch(widget.link);
      }
      if(widget.gifs.isNotEmpty)
        gifyStickers = widget.gifs;
      mature = widget.mature;
    }
    setState(() {});
  }

  mediaSendToChat(){
    DateTime now = DateTime.now();
    int time = now.microsecondsSinceEpoch;

    Map imgObj = {
      "imgPath":widget.filePath != null ? widget.filePath : widget.file.path,
      "imgName":widget.vidOrAud ? "$time.mp4" : "$time.jpeg",
      "caption":captionEditingController.text,
      "gifs":conGifMap(gifyStickers),
      "mature":mature,
      "link":linkEditingController.text
    };

    fileUploadToChats(
      file:widget.file != null ? widget.file : File(widget.filePath),
      personalChatId: widget.personalChatId,
      contactId:widget.contactId,
      friend:widget.friend,
      groupChatId:widget.groupChatId,
      imgObj:imgObj,
      time:time,
    );
  }

  mediaListSendToChats(){
    DateTime now = DateTime.now();
    fileUploadToChats(
      file: mediaList.length == 1 ? File(mediaList[0]["imgPath"]) : null,
      personalChatId: widget.personalChatId,
      contactId:widget.contactId,
      friend:widget.friend,
      groupChatId:widget.groupChatId,
      imgObj:mediaList.length == 1 ? mediaList[0] : null,
      mediaGallery: mediaList.length > 1 ? mediaList : null,
      time:now.microsecondsSinceEpoch,
    );
  }

}

