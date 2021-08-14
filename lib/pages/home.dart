import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/user.dart';
import 'package:wemeet/providers/data.dart';

import 'package:wemeet/services/message.dart';
import 'package:wemeet/services/match.dart';
import 'package:wemeet/services/socket_bg.dart';
import 'package:wemeet/services/audio.dart';
import 'package:wemeet/services/user.dart';

import 'package:wemeet/utils/svg_content.dart';
import 'package:wemeet/config.dart';

import 'package:wemeet/pages/match.dart';
import 'package:wemeet/pages/profile.dart';
import 'package:wemeet/pages/playlist.dart';
// import 'package:wemeet/pages/subscription.dart';

class HomePage extends StatefulWidget {

  final AppModel model;
  const HomePage({Key key, this.model}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _currentPage = 0;

  WeMeetAudioService _audioService = WeMeetAudioService();
  BackgroundSocketService _socketBgService = BackgroundSocketService();

  DataProvider dp = DataProvider();
  StreamSubscription<int> _navStream;

  ThemeData theme;
  MediaQueryData mQuery;

  @override
  void initState() { 
    super.initState();

    _navStream = dp.onNavPageChanged.listen(_onNavChanged);

    // get message token
    getMessageToken();

    // update user matches
    updateMatches();

    startSocketConn();

    // update profile
    updateProfile();
    
  }

  @override
  void dispose() { 
    _audioService?.stop();
    _audioService?.dispose();
    _navStream?.cancel();
    _socketBgService?.stop();
    super.dispose();
  }

  void startSocketConn() {
    _socketBgService.start(WeMeetConfig.socketUrl);
  }

  void _onNavChanged(int val) {
    if (mounted && val < 3) {
      setState(() {
        _currentPage = val;
      });
    }
  }

  void getMessageToken() {
    MessageService.postLogin().then((res){
      String data = res["data"]["accessToken"] as String;
      print("Message Token: $data");
      widget.model.setMessageToken(data);

      List list = (widget.model.chatList ?? {}).keys.toList();
      BackgroundSocketService().joinRooms(list);
    });
  }

  void updateMatches() {
    MatchService.getMatches().then((res){
      List data = res["data"]["content"] as List;

      Map mtL = widget.model.matchList ?? {};

      data.map((e) => UserModel.fromMap(e)).toList().forEach((u) {
        mtL["${u.id}"] = {"name": u.fullName, "image": u.profileImage};
      });

      widget.model.setMatchList(mtL);
    });
  }

  void updateProfile() {
    UserService.getProfile().then((res){
      Map data = res["data"] as Map;
      widget.model.setUserMap(data);
    });
  }

  Widget buildBody() {
    double opacity(int index) {
      return index == _currentPage ? 1.0 : 0.0;
    }

    return Stack(
      children: <Widget>[
        IgnorePointer(
          ignoring: _currentPage != 0,
          child: Opacity(
            opacity: opacity(0),
            child: MatchPage(model: widget.model),
          ),
        ),
        IgnorePointer(
          ignoring: _currentPage != 1,
          child: Opacity(
            opacity: opacity(1),
            child: PlaylistPage(),
          ),
        ),
        IgnorePointer(
          ignoring: _currentPage != 2,
          child: Opacity(
            opacity: opacity(2),
            child: ProfilePage(),
          ),
        ),
        // IgnorePointer(
        //   ignoring: _currentPage != 3,
        //   child: Opacity(
        //     opacity: opacity(3),
        //     child: SubscriptionPage(),
        //   ),
        // )
      ],
    );
  }

  Widget _buildBottomNav() {

    List<BottomNavigationBarItem> items = <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: SvgPicture.string(WemeetSvgContent.homeOutline, height: 23.0,),
          label: "Home",
          activeIcon: SvgPicture.string(WemeetSvgContent.home, height: 23.0,),
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.string(WemeetSvgContent.playlistOutline, height: 23.0,),
          label: "Playlist",
          activeIcon: SvgPicture.string(WemeetSvgContent.playlist, height: 23.0,),
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.string(WemeetSvgContent.userOutline, height: 23.0,),
          label: "Profile",
          activeIcon: SvgPicture.string(WemeetSvgContent.user, height: 23.0,),
        ),
        // BottomNavigationBarItem(
        //   icon: SvgPicture.string(WemeetSvgContent.cardOutline, height: 20.0,),
        //   label: "Subscription",
        //   activeIcon: SvgPicture.string(WemeetSvgContent.card, height: 20.0,),
        // ),
    ];

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentPage,
      items: items,
      elevation: 0.0,
      selectedItemColor: theme.accentColor,
      onTap: (index){
        FocusScope.of(context).requestFocus(FocusNode());
        setState(() {
          _currentPage = index;
        });
      },
      backgroundColor: Colors.white,
      selectedFontSize: 10.0,
      unselectedFontSize: 10.0,
      selectedLabelStyle: TextStyle(
        height: 1.6
      ),
      iconSize: 20.0
    );
  }

  @override
  Widget build(BuildContext context) {

    theme = Theme.of(context);
    mQuery = MediaQuery.of(context);

    return Scaffold(
      body: buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
}