import 'package:SpidrApp/widgets/mediaAndFilePicker.dart';
import 'package:flutter/material.dart';

class UploadBttSheetWrapper extends StatefulWidget {
  final ScrollController controller;
  final String groupId;
  final String personalChatId;
  final bool friend;
  final String contactId;
  final int numOfAvlUpl;
  final String uploadTo;

  final bool singleFile;

  UploadBttSheetWrapper(
      this.controller,
      this.groupId,
      this.personalChatId,
      this.friend,
      this.contactId,
      this.numOfAvlUpl,
      this.uploadTo,
      this.singleFile
      );
  @override
  _UploadBttSheetWrapperState createState() => _UploadBttSheetWrapperState();
}

class _UploadBttSheetWrapperState extends State<UploadBttSheetWrapper> {

  PageController pageController;

  int selected = 0;

  @override
  void initState() {
    // TODO: implement initState
    pageController = new PageController(initialPage: selected);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (widget.singleFile == null || !widget.singleFile) &&
        (widget.groupId != null || widget.personalChatId != null) ?
    Stack(
      children: [
        PageView(
          controller: pageController,
          onPageChanged: (int page){
            setState(() {
              selected = page;
            });
          },
          children: [
            MediaAndFileGallery(
              controller: widget.controller,
              groupId: widget.groupId,
              personalChatId: widget.personalChatId,
              friend: widget.friend,
              contactId: widget.contactId,
              uploadTo: widget.uploadTo,
              type: "MEDIA",
            ),
            MediaAndFileGallery(
              controller: widget.controller,
              groupId: widget.groupId,
              personalChatId: widget.personalChatId,
              friend: widget.friend,
              contactId: widget.contactId,
              uploadTo: widget.uploadTo,
              type: "AUDIO",
            ),
            MediaAndFileGallery(
              controller: widget.controller,
              groupId: widget.groupId,
              personalChatId: widget.personalChatId,
              friend: widget.friend,
              contactId: widget.contactId,
              uploadTo: widget.uploadTo,
              type: "PDF",
            ),
          ],
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                tabBar("MEDIA", Icons.image_rounded, 0),
                tabBar("AUDIO", Icons.music_note_rounded, 1),
                tabBar("PDF", Icons.insert_drive_file_rounded, 2),
              ],
            ),
          ),
        )
      ],
    ) : MediaAndFileGallery(
      controller: widget.controller,
      uploadTo: widget.uploadTo,
      numOfAvlUpl: widget.numOfAvlUpl,
      type: "MEDIA",
      singleFile: widget.singleFile,
      personalChatId: widget.personalChatId,
      friend: widget.friend,
      contactId: widget.contactId,
      groupId: widget.groupId,
    );
  }

  Widget tabBar(String type, icon, int index){
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: selected == index ? Colors.orange : Colors.white
      ),
      child: TextButton.icon(
          onPressed: (){
            setState(() {
              selected = index;
            });
            pageController.jumpToPage(selected);
          },
          icon: Icon(icon, color: Colors.black,),
          label: Text(type, style: TextStyle(fontSize: 12.5, color: Colors.black, fontWeight: FontWeight.bold),)
      ),
    );
  }
}
