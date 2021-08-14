import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:async';

import 'package:wemeet/models/user.dart';
import 'package:wemeet/models/app.dart';

import 'package:wemeet/services/match.dart';
import 'package:wemeet/providers/data.dart';

import 'package:wemeet/pages/match_found.dart';
import 'package:wemeet/pages/chat.dart';
import 'package:wemeet/pages/user_details.dart';

import 'package:wemeet/components/media_player.dart';
import 'package:wemeet/components/loader.dart';
import 'package:wemeet/components/error.dart';
import 'package:wemeet/utils/colors.dart';
import 'package:wemeet/utils/svg_content.dart';

class MatchPage extends StatefulWidget {

  final AppModel model;
  const MatchPage({Key key, this.model}) : super(key: key);

  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {

  int swipesLeft = 0;
  bool isLoading = false;
  int left = 0;
  List<UserModel> users = [];

  DataProvider _dataProvider = DataProvider();
  StreamSubscription<String> reloadStream;

  CardController controller = CardController();

  MediaQueryData mQuery;

  @override
  void initState() { 
    super.initState();
    
    reloadStream = _dataProvider.onReloadPage.listen(onReload);

    fetchData(false);
    // getSuggestion();
  }

  @override
  void dispose() { 
    reloadStream?.cancel();
    super.dispose();
  }

  void fetchData([bool test = false]) async {

    if(test) {
      setState(() {
        users = List.generate(5, (i) => UserModel(
          id: i,
          firstName: "John $i",
          lastName: "Doe",
          profileImage: "https://uifaces.co/our-content/donated/gPZwCbdS.jpg",
          dob: 968093489867,
          distanceInKm: 20,
        )); 
      });

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var res = await MatchService.getSuggestion();
      Map data = res["data"];
      List u = data["profiles"] as List; 

      setState(() {
        users = u.map((e) => UserModel.fromMap(e)).toList();
        // users.removeWhere((e) => e.profileImage == null);
        swipesLeft = data["swipesLeft"];   
        left = users.length;     
      });

    } catch (e) {

    } finally {
      setState((){
        isLoading = false;
      });
    }
  }

  void showMatch(UserModel match, bool show) async {

    if(!show || match == null) {
      return;
    }

    // add the match to the local database
    addMatch(match);

    _dataProvider.setNavPage(0);

    await Future.delayed(Duration(seconds: 1));

    String id = "${match?.id}";

    bool go = await Navigator.push(context, MaterialPageRoute(
      builder: (context) => MatchFoundPage(match: match),
      fullscreenDialog: true
    )) ?? false;

    if(!go) {
      return;
    }

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChatPage(uid: id)
    ));
    
  }

  void addMatch(UserModel match) {
    Map mL = widget.model.matchList ?? {};
    mL["${match.id}"] = {"name": match.fullName, "image": match.profileImage ?? "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png"};
    widget.model.setMatchList(mL);
  }

  void onReload(String val) {
    if(!mounted) {
      return;
    }

    if(val.split(",").contains("match")) {
      fetchData();
    }

  }

  void postSwipe(int id, String action, [bool ]) {

    print("Posting Swipe");

    UserModel uMatch = users.firstWhere((e) => e.id == id, orElse: () => null);
    
    setState(() {
      left = left - 1;
      users.removeWhere((e) => e.id == id);      
    });

    if(swipesLeft == 0) {
      _showUpgrade();
      return;
    }

    MatchService.postSwipe({"swipeeId": id, "type": action}).then((res){
      setState(() {
        swipesLeft = swipesLeft - 1;        
      });

      Map data = res["data"];
      showMatch(uMatch, data["match"] ?? false);
    }).catchError(print);
  }

  void _showUpgrade() async {
    bool val = await WeMeetLoader.showBottomModalSheet(
      context,
      "Out of Swipes.",
      content: "Unfortunately you are out of swipes for today. Would you like t upgrade to enjoy unlimited swipes?",
      cancelText: "No, thanks",
      okText: "Yes, please!",
    );

    if(!val) {
      return;
    }

    DataProvider().setNavPage(3);
    
  }

  void viewUser(UserModel u, int index) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => UserDetailsPage(
        user: u,
        tag: "$index#${u.id}",
        onSwipe: (val) {
          if(val == null) {
            return;
          }

          if(val) {
            controller.triggerRight();
          } else {
            controller.triggerLeft();
          }
        },
      ),
      fullscreenDialog: true
    ));
  }

  Widget _swipeBtn(String icon, [bool left = false]) {
    return InkWell(
      onTap: () {
        if(left) {
          controller.triggerLeft();
        } else {
          controller.triggerRight();
        }
      },
      child: Container(
        width: 50.0,
        height: 50.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.orangeColor.withOpacity(0.06)
        ),
        child: SvgPicture.string(
          icon,
          color: AppColors.orangeColor
        ),
      ),
    );
  }

  Widget buildSwipes() {
    return Container(
      height: mQuery.size.height * 0.50,
      constraints: BoxConstraints(
        maxHeight: 500.0
      ),
      child: TinderSwapCard(
        cardController: controller,
        swipeUp: false,
        swipeDown: false,
        orientation: AmassOrientation.TOP,
        totalNum: users.length,
        stackNum: 2,
        swipeEdge: 10.0,
        allowVerticalMovement: false,
        maxWidth: mQuery.size.width * 0.95,
        // maxHeight: mQuery.size.width * 0.95,
        maxHeight: 500,
        minWidth: mQuery.size.width * 0.80,
        minHeight: mQuery.size.width * 0.70,
        swipeCompleteCallback: (orientation, index){
          print("#####Swiped: $orientation");
          if (orientation == CardSwipeOrientation.LEFT) {
            postSwipe(users[index].id, "UNLIKE");
          }

          if (orientation == CardSwipeOrientation.RIGHT) {
            postSwipe(users[index].id, "LIKE");
          }
        },
        swipeUpdateCallback: (details, align) {

        },
        cardBuilder: (context, index) {
          UserModel item = users[index];
          return GestureDetector(
            onTap: () {
              viewUser(item, index);
            },
            child: Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: "$index#${item.id}",
                      child: CachedNetworkImage(
                        imageUrl: item.profileImage ?? "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png",
                        placeholder: (context, _) => DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            gradient: LinearGradient(
                              begin: FractionalOffset.topCenter,
                              end: FractionalOffset.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.2),
                                Colors.black.withOpacity(0.9),
                              ],
                            )
                          ),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        gradient: LinearGradient(
                          begin: FractionalOffset.topCenter,
                          end: FractionalOffset.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.01),
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: [0.6, 1.0]
                        )
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "${item.firstName}, ${item.age}",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15.0
                            ),
                          ),
                          SizedBox(height: 5.0,),
                          Text(
                            "${item.distanceInKm ?? 1} Km Away",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w700
                            ),
                          ),
                        ],
                      )
                    ),
                  )
                ],
              ),
            ),    
          );
        },
      ),
    );
  }

  Widget buildSwipeBtns() {
    return Wrap(
      spacing: 20.0,
      alignment: WrapAlignment.center,
      children: [
        _swipeBtn(WemeetSvgContent.cancel, true),
        _swipeBtn(WemeetSvgContent.heartY, false)
      ],
    );
  }

  Widget buildBody() {

    if(isLoading && users.isEmpty) {
      return WeMeetLoader.showBusyLoader(color: AppColors.color1);
    }

    if(users.isEmpty) {
      return WErrorComponent(
        text: "No Match Found",
        icon: Ionicons.heart_circle_outline,
        buttonText: "Retry",
        callback: () => fetchData(false),
      );
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 30.0),
          buildSwipes(),
          SizedBox(height: 15.0),
          buildSwipeBtns(),
          Spacer(),
          // WMEdiaPlayer(occupy: false,)
        ],
      ),
    );

  }

  Widget buildMain() {

    return Column(
      children: [
        Expanded(
          child: buildBody(),
        ),
        // SizedBox(height: 15.0),
        // buildSwipeBtns(),
        // buildBody(),
        // Spacer(),
        WMEdiaPlayer(occupy: true,)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    mQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("WeMeet"),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: (){
              Navigator.pushNamed(context, "/messages");
            },
            icon: Icon(FeatherIcons.messageSquare),
          )
        ],
      ),
      body: buildMain(),
    );
  }
}