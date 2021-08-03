import 'package:SpidrApp/decorations/widgetDecorations.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';

class AboutSpidrScreen extends StatelessWidget {

  launchSite(String url){
    FlutterWebBrowser.openWebPage(
        url: url,
        customTabsOptions: CustomTabsOptions(
          colorScheme: CustomTabsColorScheme.dark,
          toolbarColor: Colors.orange,
          secondaryToolbarColor: Colors.orangeAccent,
          navigationBarColor: Colors.black,
          addDefaultShareMenuItem: true,
          instantAppsEnabled: true,
          showTitle: true,
          urlBarHidingEnabled: true,
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Icon(Icons.info_rounded),
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Image.asset(
                  "assets/icon/appIcon.png",
                  height: 91,
                  width: 91,
                  fit: BoxFit.contain,
                ),
                Text(
                  "Spidr",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                ),
                Text(
                  "Version 1.1.0",
                  style: TextStyle(color: Colors.black)
                ),
              ],
            ),

            Container(
              height: MediaQuery.of(context).size.height*0.45,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            color: Colors.white,
                            boxShadow: [
                              circleShadow
                            ]
                        ),
                        child: ListTile(
                          title: Text(
                            "Terms and Conditions",
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)
                          ),
                          trailing: iconContainer(
                            icon:Icons.chevron_right_rounded,
                            contColor: Colors.black,
                            horPad: 5,
                            verPad: 5,
                          ),
                          onTap: (){
                            launchSite("https://www.iubenda.com/terms-and-conditions/80156886");
                          }
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            color: Colors.white,
                            boxShadow: [
                              circleShadow
                            ]
                        ),
                        child: ListTile(
                            title: Text(
                                "What's New",
                                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)
                            ),
                            trailing: iconContainer(
                              icon:Icons.chevron_right_rounded,
                              contColor: Colors.black,
                              horPad: 5,
                              verPad: 5,
                            ),
                            onTap:(){
                              launchSite("https://www.spidrapp.com/");
                            }
                        ),
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      Text(
                          "Copyright \u00a9 2021-2031 Brane",
                          style: TextStyle(color: Colors.grey, fontSize: 12)
                      ),
                      Text(
                          "All Rights Reserved",
                          style: TextStyle(color: Colors.grey, fontSize: 12)
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
