import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
// import 'package:ionicons/ionicons.dart';

import 'package:wemeet/components/error.dart';
import 'package:wemeet/components/loader.dart';
import 'package:wemeet/components/playlist_item.dart';
import 'package:wemeet/components/song_cover.dart';
import 'package:wemeet/components/song_request.dart';

import 'package:wemeet/models/song.dart';

import 'package:wemeet/services/music.dart';
import 'package:wemeet/services/audio.dart';

class PlaylistPage extends StatefulWidget {
  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {

  WeMeetAudioService _audioService = WeMeetAudioService();

  List<SongModel> items = []; 

  bool isLoading = false;
  String errorText;

  @override
  void initState() { 
    super.initState();
    
    fetchData();

  }

  void fetchData() async {

    setState(() {
      isLoading = true;
      errorText = null;      
    });

    try {
      var res = await MusicService.getList();
      List data = res["data"]["content"] as List;

      setState(() {
        items = data.map((e) => SongModel.fromMap(e)).toList();        
      });

      _prepareQueue(items);

    } catch (e) { 
      print(e);
    } finally {
      setState(() {
        isLoading = false;        
      });
    }
  }

  void _prepareQueue(List<SongModel> val) {
    _audioService?.start();
    _audioService.setQueue(val);
  }

  void requestSong() {
    showDialog(
      context: context,
      builder: (context) => SongRequestDialog()
    );
  }

  Widget buildRequest() {
    return Container(
      margin: EdgeInsets.only(top: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Music Requests",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 17,
              ),
            ),
          ),
          SizedBox(height: 20.0),
          SizedBox(
            height: 210.0,
            child: ListView.builder(
              itemBuilder: (context, index) => WSongCover(song: items[index],),
              itemCount: items.length,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildList() {
    return Container(
      margin: EdgeInsets.only(top: 50.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              "Daily Playlist",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 17,
              ),
            ),
          ),
          SizedBox(height: 20.0),
          ListView.separated(
            itemBuilder: (context, index) => WPlaylisItem(song: items[index]),
            separatorBuilder: (context, index) => Divider(
              indent: 60.0,
            ),
            itemCount: items.length,
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
          ),
        ],
      ),
    );
  }

  Widget buildBody() {

    if(isLoading && items.isEmpty) {
      return WeMeetLoader.showBusyLoader();
    }

    if(errorText != null && items.isEmpty) {
      return WErrorComponent(
        text: errorText,
        callback: fetchData,
      );
    }

    if(items.isEmpty) {
      return WErrorComponent(
        text: "Playlist is empty.",
        callback: fetchData,
        icon: FeatherIcons.music,
      );
    }


    return SingleChildScrollView(
      child: Column(
        children: [
          buildRequest(),
          buildList()
        ],
      ),
    );
  }

  Widget buildAppBar() {
    return AppBar(
      title: Text("Today's Playlist"),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: requestSong,
          icon: Icon(Icons.add),
        )
      ],
      /*bottom: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 13.0),
          margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Color(0xFFf2f2f2),
            borderRadius: BorderRadius.circular(5.0)
          ),
          child: Row(
            children: [
              Icon(Ionicons.search_outline, size: 20.0, color: Colors.grey),
              SizedBox(width: 10.0),
              Expanded(
                child: TextField(
                  decoration: InputDecoration.collapsed(
                    hintText: "Search by title, artist",
                    hintStyle: TextStyle(
                      color: Colors.grey
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),*/
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(),
    );
  }
}