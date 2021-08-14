import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'dart:async';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/user.dart';
import 'package:wemeet/pages/chat.dart';

import 'package:wemeet/services/match.dart';

import 'package:wemeet/utils/colors.dart';

import 'package:wemeet/utils/errors.dart';

import 'package:wemeet/components/search_field.dart';
import 'package:wemeet/components/error.dart';
import 'package:wemeet/components/loader.dart';

class MatchesPage extends StatefulWidget {

  final AppModel model;
  const MatchesPage({Key key, this.model}) : super(key: key);

  @override
  _MatchesPageState createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {

  bool isLoading = false;
  bool isError = false;
  String errorText;
  List<UserModel> items = [];
  String query = "";

  Timer _debounce;

  AppModel model;
  UserModel user;

  @override
  void initState() { 
    super.initState();

    model = widget.model;
    user = model.user;
    
    fetchData();
  }

  void fetchData() async {

    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {
      var res = await MatchService.getMatches();
      List data = res["data"]["content"] as List;
      // print(data);
      setState(() {
        items = data.map((e) => UserModel.fromMap(e)).toList();
      });
      _saveMatches();

    } catch (e) {
      setState(() {
        errorText = kTranslateError(e);
      });

    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _saveMatches() {
    Map mtL = widget.model.matchList ?? {};

    items.forEach((u) {
      mtL["${u.id}"] = {"name": u.fullName, "image": u.profileImage};
    });

    widget.model.setMatchList(mtL);
  }

  void search(String val){

    //Delay Api call by a second
    bool active = _debounce?.isActive ?? false;
    if (active) {
      _debounce.cancel();
    } 
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if(!mounted) return;
      setState(() {
        query = val;        
      });;
    });
  }

  List<UserModel> get matches {

    if(items.isEmpty) {
      return [];
    }

    return items.where((i) {
      String name = i.fullName.toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();
  }

  Widget _iconBtn(IconData icon, VoidCallback callback) {
    return InkWell(
      onTap: callback,
      child: Icon(icon, size: 20.0),
    );
  }

  Widget buildItem(UserModel match) {
    return Container(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(match.profileImage),
        ),
        title: Text("${match.fullName}"),
        trailing: Wrap(
          spacing: 25.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _iconBtn(
              FeatherIcons.messageSquare, 
              () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ChatPage(uid: "${match.id}",)
                ));
              }
            ),
            // _iconBtn(FeatherIcons.trash, () => Navigator.pushNamed),
          ],
        ),
      ),
    );
  }

  Widget buildList() {
    return ListView.separated(
      itemBuilder: (context, index) => buildItem(matches[index]),
      separatorBuilder: (context, index) => Divider(indent: 80.0,),
      itemCount: matches.length,
      padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    );
  }

  Widget buildBody() {
    if(isLoading && matches.isEmpty) {
      return WeMeetLoader.showBusyLoader(color: AppColors.color1);
    }

    if(isError && matches.isEmpty) {
      return WErrorComponent(text: errorText, callback: fetchData,);
    }

    if(matches.isEmpty) {
      return Center(
        child: Icon(FeatherIcons.messageSquare, size: 60.0, color: Colors.black38),
      );
    }

    return buildList();
  }

  Widget buildAppBar() {
    return AppBar(
      title: Text("Matches"),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: WSearchField(
            hintText: "Search by name",
            onChanged: search,
          ),
        ),
      ),
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