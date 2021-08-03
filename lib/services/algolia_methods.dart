import 'dart:math';

import 'package:SpidrApp/algolia_const.dart';
import 'package:SpidrApp/helper/constants.dart';
import 'package:algolia/algolia.dart';

class AlgoliaMethods {

  static final Algolia algolia = Algolia.init(applicationId: AlgoliaConst.APP_ID, apiKey: AlgoliaConst.API_SEARCH_KEY);
  static final AlgoliaIndexReference groupChats = algolia.instance.index("groupChats");
  static final AlgoliaIndexReference users = algolia.instance.index("users");
  static final AlgoliaIndexReference mediaItems = algolia.instance.index("mediaItems");

  static final random = Random();

  static searchUsers(String searchText) {
    return Stream.fromFuture(users.search(searchText).getObjects());
  }

  static searchGroupChats(String searchText) {
    return Stream.fromFuture(groupChats.search(searchText)
        .setFilters("NOT chatRoomState:invisible AND NOT deleted:true").getObjects()
    );
  }

  static getMedia(String searchText){
    return Stream.fromFuture(mediaItems.search(searchText).setFilters("media:true AND NOT notVisibleTo:"+Constants.myUserId).getObjects());
  }

  static getMediaAud(String searchText){
    return Stream.fromFuture(mediaItems.search(searchText).setFilters("audio:true AND NOT notVisibleTo:"+Constants.myUserId).getObjects());
  }

  static getMediaPDF(String searchText){
    return Stream.fromFuture(mediaItems.search(searchText).setFilters("pdf:true AND NOT notVisibleTo:"+Constants.myUserId).getObjects());
  }

  static List _shuffle(List items) {
    for (var i = items.length - 1; i > 0; i--){
      var n = random.nextInt(i + 1);
      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }
    return items;
  }

  static _addHotTag(List hotTags, Set groupTags){
    int randIndex = random.nextInt(hotTags.length);
    if(!groupTags.contains(hotTags[randIndex])){
      groupTags.add(hotTags[randIndex]);
      hotTags.removeAt(randIndex);
    }
  }

  static Future<List<String>> getSugTags(List hotTags, int max) async{

    Set<String> groupTags = {};
    AlgoliaQuerySnapshot result = await groupChats.setFilters("NOT chatRoomState:invisible AND NOT deleted:true").getObjects();
    int resLength = result.hits.length;
    List resIndices = [for(int i = 0; i < resLength; i++) i];

    int range = resLength < max ? resLength : max ~/ 3;

    for(int i = 0; i < range; i++){
      if(resIndices.length > 0){
        int randIndex = random.nextInt(resIndices.length);

        AlgoliaObjectSnapshot groupAS = result.hits[resIndices[randIndex]];
        List tags = groupAS.data["tags"];

        if(tags != null && tags.isNotEmpty){
          int randTag = random.nextInt(tags.length);
          if(tags[randTag].length > 1 && !groupTags.contains(tags[randTag]))
            groupTags.add(tags[randTag]);
          else _addHotTag(hotTags, groupTags);
        } else _addHotTag(hotTags, groupTags);

        resIndices.removeAt(randIndex);
      }
    }

    int numOfLeft = max - groupTags.length;
    for(int i = 0; i < numOfLeft; i++)
      _addHotTag(hotTags, groupTags);

    return _shuffle(groupTags.toList());
  }

  static getStreamGroups(String searchText, bool oneDay){
    String filter = !oneDay ?
    "NOT chatRoomState:invisible AND NOT deleted:true" :
    "oneDay:true AND NOT chatRoomState:invisible AND NOT deleted:true";

    return Stream.fromFuture(groupChats.search(searchText)
        .setFilters(filter).getObjects());
  }

  static getSuggestedGroups(List tags)async{
    final int max = 9;
    final String filter = "NOT chatRoomState:invisible AND NOT deleted:true AND NOT members:"+Constants.myUserId;
    Set<AlgoliaObjectSnapshot> sugGroups = {};
    AlgoliaQuerySnapshot allGroups = await groupChats
        .setFilters(filter)
        .getObjects();

    AlgoliaQuerySnapshot matchGroups;
    int randIndex;
    int range = allGroups.hits.length < max ? allGroups.hits.length : max;
    List matchTags = [];

    if(tags.isNotEmpty){
      matchGroups = await groupChats.search(tags.join(" ")).setFilters(filter).getObjects();
      if(matchGroups.hits.length > 0){
        int matchRange = matchGroups.hits.length < (range/2).ceil() ? matchGroups.hits.length : (range/2).ceil();
        for(int i = 0; i < matchRange; i++){
          randIndex = random.nextInt(matchGroups.hits.length);
          sugGroups.add(matchGroups.hits[randIndex]);
          matchTags.add(matchGroups.hits[randIndex].data["hashTag"]);
        }
      }
    }

    if(allGroups.hits.length > 0){
      int numOfLeft = range-sugGroups.length;
      for(int i = 0; i<numOfLeft; i++){
        randIndex = random.nextInt(allGroups.hits.length);
        if(!matchTags.contains(allGroups.hits[randIndex].data["hashTag"]))
          sugGroups.add(allGroups.hits[randIndex]);
      }
    }

    return _shuffle(sugGroups.toList());
  }


  static getSuggestedUsers(List tags)async{
    final int max = 9;
    // final String filter = "NOT chatRoomState:invisible AND NOT deleted:true AND NOT members:"+Constants.myUserId;
    Set<AlgoliaObjectSnapshot> sugUsers = {};

    AlgoliaQuerySnapshot matchUsers = await users.search(tags.join(" ")).getObjects();
    List muIndices = [for(int i = 0; i < matchUsers.hits.length; i++) i];
    List matchUserIds = [];
    int range = matchUsers.hits.length < max ? matchUsers.hits.length : max;

    for(int i = 0; i < range; i++){
      int randIndex = random.nextInt(muIndices.length);
      String userId = matchUsers.hits[randIndex].objectID;
      if(userId != Constants.myUserId){
        sugUsers.add(matchUsers.hits[randIndex]);
        matchUserIds.add(userId);
      }

      muIndices.removeAt(randIndex);
    }

    int numOfLeft = max - sugUsers.length;
    if(numOfLeft > 0){
      AlgoliaQuerySnapshot allUsers = await users.getObjects();
      List auIndices = [for(int i = 0; i < allUsers.hits.length; i++) i];
      for(int i = 0; i < numOfLeft; i++){
        if(auIndices.length > 0){
          int randIndex = random.nextInt(auIndices.length);
          String userId = allUsers.hits[randIndex].objectID;
          if(userId != Constants.myUserId && !matchUserIds.contains(userId))
            sugUsers.add(allUsers.hits[randIndex]);
          auIndices.removeAt(randIndex);
        }
      }
    }

    return _shuffle(sugUsers.toList());
  }



}