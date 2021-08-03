import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget searchIcon(){
  return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                const Color(0xFFFF9800),
                const Color(0xFFFF9800)
              ]
          ),
          borderRadius: BorderRadius.circular(40)
      ),
      padding: EdgeInsets.all(12),
      child: Image.asset("assets/images/search.png")
  );
}



searchBar({TextEditingController searchEditingController, String searchType, Function searchChats, Function searchUsers}){
  return Container(
    color: Colors.white,
    padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
    child: Row(
      children: [
        searchIcon(),
        SizedBox(width: 15,),
        Expanded(
            child: TextField(
              controller: searchEditingController,
              onChanged: (String val){
                if(searchType == "CIRCLE") searchChats(val);
                else if(searchType == "USER") searchUsers(val);
              },
              style: TextStyle(color: Colors.black),

              decoration: InputDecoration(
                hintText: searchType == "CIRCLE" ? "Search for circle" : "Search for user",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
            )
        ),
      ],
    ),
  );
}