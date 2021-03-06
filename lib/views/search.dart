import 'package:SpidrApp/views/groupsList.dart';
import 'package:SpidrApp/views/usersList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen();

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {

  String searchText = '';


  TextEditingController searchEditingController = new TextEditingController();

  int selectedIndex = 0;

  // final PageController pageController = PageController(initialPage: 0, keepPage: true);
  TabController tabController;


  void pageChanged(int index){
    setState((){
      selectedIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1.0,
          title: Container(
            padding: EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
                color: Colors.grey[200], borderRadius: BorderRadius.circular(30)
            ),
            child: TextField(
              autofocus: true,
              controller: searchEditingController,
              onChanged: (String val){
                setState(() {
                  searchText = val;
                });
              },
              decoration: InputDecoration(
                icon: Icon(Icons.search),
                border: InputBorder.none,
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.grey)
              ),
            ),
          ),
          bottom: TabBar(
            controller: tabController,
            indicatorColor: Colors.orange,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                text: "Circles",
              ),
              Tab(
                text: "Users",
              ),
            ],
          ),
        ),
        body:TabBarView(
          controller: tabController,
          children: [
            GroupsList(searchText),
            UsersList(searchText),
          ],
        )


        // Container(
        //   color: Colors.white,
        //   child: Column(
        //     children: [
        //
        //       PageView(
        //         controller: pageController,
        //         children: [
        //           GroupsList(searchEditingController.text),
        //           UsersList(searchEditingController.text),
        //         ],
        //         onPageChanged: pageChanged,
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }
}




