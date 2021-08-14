import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/user.dart';

import 'package:wemeet/services/user.dart';

import 'package:wemeet/components/loader.dart';
import 'package:wemeet/components/error.dart';

import 'package:wemeet/utils/errors.dart';
import 'package:wemeet/utils/colors.dart';
import 'package:wemeet/utils/toast.dart';

class BlockedUsersPage extends StatefulWidget {

  final AppModel model;
  const BlockedUsersPage({Key key, this.model}) : super(key: key);

  @override
  _BlockedUsersPageState createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {

  bool isLoading = false;
  String errorText;
  bool isError = false;

  int page = 0;
  int perPage = 30;

  List<UserModel> users = [];

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
      isError = false;   
    });

    try {
      var res = await UserService.getBlockedUsers({"pageNum": page, "pageSize": perPage});
      List data = res["data"]["content"] as List;

      setState(() {
        users = data.map((e) => UserModel.fromMap(e)).toList();        
      });

    } catch (e) { 
      print(e);
      setState(() {
        isError = true;
        errorText = kTranslateError(e);        
      });
    } finally {
      setState(() {
        isLoading = false;        
      });
    }
  }

  void unblockUser(int id) async {

    bool val = await WeMeetLoader.showBottomModalSheet(
      context,
      "Unblock User?",
      content: "Are you sure you want to unblock this user?",
      okText: "Yes, Unblock",
      cancelText: "Cancel"
    );

    if(!val) {
      return;
    }

    WeMeetLoader.showLoadingModal(context);

    try {
      await UserService.postUnblockUser("$id");
      setState(() {
        users.removeWhere((e) => e.id == id);        
      });
      WeMeetToast.toast("User unblocked successfully");
    } catch (e) {
      WeMeetToast.toast(kTranslateError(e), true);
    } finally {
      if(Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }


  }

  Widget buildItem(UserModel item) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(item.profileImage),
      ),
      title: Text("${item.fullName}"),
      // subtitle: Text(
      //   "Joined ${item.createdF ?? ""}"
      // ),
      trailing: GestureDetector(
        onTap: () => unblockUser(item.id),
        child: Container(
          height: 30.0,
          width: 80.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.4),
            borderRadius: BorderRadius.circular(5.0)
          ),
          child: Text(
            "Unblock",
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.white
            ),
          )
        ),
      ),
    );
  }

  Widget buildBody() {

    // return buildItem(user);

    if(isLoading && users.isEmpty) {
      return WeMeetLoader.showBusyLoader(color: AppColors.color1);
    }

    if(isError && users.isEmpty) {
      return WErrorComponent(text: errorText, callback: fetchData,);
    }

    if(users.isEmpty) {
      return Center(
        child: Icon(FeatherIcons.users, size: 60.0, color: Colors.black38),
      );
    }

    return ListView.separated(
      itemBuilder: (context, index) => buildItem(users[index]),
      separatorBuilder: (context, index) => Divider(indent: 80.0,),
      itemCount: users.length,
      padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Blocked Users"),
      ),
      body: buildBody(),
    );
  }
}