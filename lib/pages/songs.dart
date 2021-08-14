import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wemeet/components/error.dart';
import 'package:wemeet/components/loader.dart';

import 'package:wemeet/models/song.dart';

import 'package:wemeet/services/music.dart';

import 'package:wemeet/utils/colors.dart';

class SongsPage extends StatefulWidget {

  final ValueChanged<String> onSelect;
  const SongsPage({Key key, this.onSelect}) : super(key: key);

  @override
  _SongsPageState createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {

  bool isLoading = false;
  bool isError = false;
  bool hasMore = false;

  int page = 0;
  int perPage = 10;

  List<SongModel> items = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() { 
    super.initState();
    
    fetchData();
  }

  void fetchData({Function onSuccess, VoidCallback onError, bool delay = false}) async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    if(delay) {
      await Future.delayed(Duration(seconds: 1));
    }

    try {
      var res = await MusicService.getList({"pageNum": page, "pageSize": perPage});

      List data = res["data"]["content"] as List;

      List<SongModel> songs = data.map<SongModel>((i) => SongModel.fromMap(i)).toList();

      setState(() {
        hasMore = perPage == songs.length;
      });

      if(onSuccess != null){
        onSuccess(songs);
      } else {
        setState(() {
          items = songs;
          hasMore = songs.length >= perPage;
        });
      }

    } catch(e){
      print(e);
      setState(() {
        isError = true;
      });
      if(onError != null) onError();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onRefresh() async {

    setState(() {
      page = 1;
    });

    fetchData(
      onSuccess: (List<SongModel> data){
        setState(() {
          items = data;
        });

        _refreshController.refreshCompleted();
      },
      onError: (){
        _refreshController.refreshFailed();
      }
    );
  }

  void _onLoadMore() async {

    setState(() {
      page++;
    });

    fetchData(
      onSuccess: (List<SongModel> data){

        if(data.isEmpty){
          _refreshController.loadNoData();
        }

        setState(() {
          items.addAll(data);
        });

        _refreshController.loadComplete();
      },
      onError: (){
        _refreshController.loadFailed();
      }
    );
  }

  Widget buildItem(SongModel song) {
    return ListTile(
      onTap: () {
        if(widget.onSelect != null) {
          widget.onSelect(song.url);
          return;
        }
      },
      leading: Icon(
        FeatherIcons.music,
        color: AppColors.color1,
      ),
      title: Text(song.title),
      subtitle: Text(song.artist,),
      trailing: Icon(FeatherIcons.upload, color: Colors.black54),
    );
  }

  Widget buildList() {
    return ListView.separated(
      itemBuilder: (context, index) => buildItem(items[index]),
      separatorBuilder: (context, index) => Divider(indent: 70.0, endIndent: 20.0,),
      itemCount: items.length,
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
    );
  }

  Widget buildBody() {
    if(items.isEmpty && isLoading) {
      return WeMeetLoader.showBusyLoader();
    }

    if(isError && items.isEmpty) {
      return WErrorComponent(callback: fetchData, text: "Error fetching songs",);
    }

    if(items.isEmpty) {
      return WErrorComponent(
        text: "No results found", 
        callback: fetchData, 
        buttonText: "Refresh",
      );
    }

    return buildList();

  }

  Widget buildAppBar() {
    return AppBar(
      title: Text("Share Songs"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: hasMore,
        onRefresh: _onRefresh,
        onLoading: _onLoadMore,
        physics: ClampingScrollPhysics(),
        child: buildBody()
      ),
    );
  }
}