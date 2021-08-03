import 'package:SpidrApp/views/viewBanner.dart';
import 'package:SpidrApp/views/mediaPreview.dart';
import 'package:SpidrApp/widgets/dialogWidgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileTagList extends StatefulWidget {
  final bool editable;
  final TextEditingController tagController;
  final List tags;
  final Function editTag;
  final Function delTag;
  final formKey;
  final int tagNum;
  final boxColor;
  final outlineColor;

  ProfileTagList({
    this.editable,
    this.tagController,
    this.tags,
    this.editTag,
    this.delTag,
    this.formKey,
    this.tagNum,
    this.boxColor = Colors.white,
    this.outlineColor = Colors.black
  });

  @override
  _ProfileTagListState createState() => _ProfileTagListState();
}

class _ProfileTagListState extends State<ProfileTagList> {

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: widget.tagNum,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index){
          return Stack(
            children: [
              GestureDetector(
                onTap:()async{
                  if(widget.editable){
                    widget.tagController.text = widget.tags.length - 1 < index ? "" : widget.tags[index];
                    if(widget.editTag != null){
                      showTextBoxDialog(
                          context: context,
                          text: "Tag",
                          textEditingController: widget.tagController,
                          errorText: "Sorry, your tag can not be empty",
                          editTag: widget.editTag,
                          formKey: widget.formKey,
                          index: index
                      );
                    }else{
                      String tag = await showTextBoxDialog(
                          context: context,
                          text: "Tag",
                          textEditingController: widget.tagController,
                          errorText: "Sorry, your tag can not be empty",
                          formKey: widget.formKey,
                          index: index
                      );
                      if(tag != null){
                        if(widget.tags.length - 1 < index){
                          widget.tags.add(tag);
                        }else{
                          widget.tags[index] = tag;
                        }
                        setState(() {});
                      }
                    }
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(right: 9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: widget.boxColor,
                    border: Border.all(
                        color: widget.outlineColor,
                        width: 2.0
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                    child: Center(
                      child: widget.editable ?
                      Text(widget.tags.length - 1 < index ? "# Add a tag" : '# '+widget.tags[index],
                        style: TextStyle(color: widget.outlineColor),
                      ) : widget.tags.length - 1 < index ?
                      Icon(Icons.tag, color: Colors.orange,) :
                      Text('# '+widget.tags[index], style: TextStyle(color: widget.outlineColor),),
                    ),
                  ),
                ),
              ),

              widget.editable && widget.tags.length - 1 >= index ?
              Positioned(
                bottom: 9,
                right: -3,
                child: IconButton(
                    icon: Icon(Icons.cancel_rounded, size: 18, color: widget.outlineColor),
                    onPressed: () {
                      if (widget.delTag != null) {
                        widget.delTag(widget.tags[index]);
                      } else {
                        setState(() {
                          widget.tags.removeAt(index);
                        });
                      }
                    }),
              ) : SizedBox.shrink()
            ],
          );
        }
    );
  }
}

Widget infoText({
  String text,
  FontWeight fontWeight = FontWeight.w600,
  double fontSize = 14,
  TextAlign textAlign,
  textColor = Colors.black
}){
  return Flexible(
      child: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: fontWeight, fontSize: fontSize,),
        textAlign: textAlign,
      )
  );
}

Widget infoEditIcon(){
  return Container(
      padding: EdgeInsets.all(2.5),
      decoration: BoxDecoration(
          color: Colors.white,
          shape:BoxShape.circle
      ),
      child: Icon(
        Icons.edit_rounded,
        size: 16,
        color: Colors.black,
      )
  );
}

Widget infoEditBtt({BuildContext context, String text, bgColor = Colors.black, fgColor = Colors.white}){
  return Container(
      width: MediaQuery.of(context).size.width*0.5,
      padding: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: bgColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text, style: TextStyle(color:fgColor, fontWeight: FontWeight.bold),),
          Icon(Icons.edit_rounded, color: fgColor,)
        ],
      )
  );
}

Widget functionBtt(BuildContext context, color, IconData icon, String text){
  return Container(
      width: MediaQuery.of(context).size.width*0.4,
      margin: EdgeInsets.symmetric(horizontal: 5),
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: color
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                text,
                style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold)
            ),
            SizedBox(width: 5,),
            Icon(icon, color: Colors.white,)
          ],
        ),
      )
  );
}

Widget schAndProgWrapper(String school, String program){
  return Container(
    height: 35,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        schAndProgDisp(
            text: Center(
                child: school != "School" ?
                Text('# '+school, style: TextStyle(color: Colors.orange)) :
                Icon(Icons.account_balance_rounded, color: Colors.orange,)
            )
        ),
        schAndProgDisp(
            text: Center(
                child: program != "Program" ? Text('# '+program, style: TextStyle(color: Colors.orange)) :
                Icon(Icons.school, color: Colors.orange,)
            )
        ),
      ],
    ),
  );
}

Widget bannerSlide({
  BuildContext context,
  double height,
  List banner,
  String userId,
  Function delTag,
  Function editTag,
  Function editAboutMe,
  formKey,
  TextEditingController quoteController,
  TextEditingController tagController
}){
  return CarouselSlider(
    items: banner.map((url) {
      int index = banner.indexOf(url);
      return GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => BannerScreen(
                index:index,
                userId: userId,
                delTag: delTag,
                editTag: editTag,
                editAboutMe: editAboutMe,
                formKey: formKey,
                quoteController: quoteController,
                tagController: tagController,
              )
          ));
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Hero(
              tag: url,
              child: ImageUrlPreview(fileURL: url,)
          ),
        ),
      );
    }).toList(),
    options: CarouselOptions(
        height: height,
        enableInfiniteScroll: banner.length > 1,
        autoPlay: true,
        viewportFraction: 1.0
    ),
  );
}

Widget schAndProgDisp({DropdownButton dropdownButton, Center text}){
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10.0),
    margin: EdgeInsets.symmetric(horizontal: 10.0),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
            color: Colors.orangeAccent,
            width: 3.0
        ),
      ),
    ),
    child: dropdownButton != null ? dropdownButton : text,
  );
}