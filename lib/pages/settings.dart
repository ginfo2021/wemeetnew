import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:location_permissions/location_permissions.dart';

import 'package:wemeet/components/wide_button.dart';
import 'package:wemeet/components/loader.dart';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/user.dart';
import 'package:wemeet/providers/data.dart';

import 'package:wemeet/services/auth.dart';
import 'package:wemeet/services/user.dart';

import 'package:wemeet/utils/colors.dart';
import 'package:wemeet/utils/errors.dart';
import 'package:wemeet/utils/toast.dart';

class SettingsPage extends StatefulWidget {

  final AppModel model;
  const SettingsPage({Key key, this.model}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  Map userData = {};

  AppModel model;
  UserModel user;

  @override
  void initState() { 
    super.initState();
    
    model = widget.model;
    user = model.user;

    userData = {
      "hideLocation": user.hideLocation,
      "hideProfile": user.hideProfile
    };

  }

  void routeTo(String page) {
    Navigator.pushNamed(context, page);
  }

  void gotoSetLocation() async {
    PermissionStatus ps = await LocationPermissions().requestPermissions();

    if(ps != PermissionStatus.granted) {
      bool val = await WeMeetLoader.showBottomModalSheet(
        context,
        "Location Permission Denied",
        content: "You need to grant WeMeeet access to your location before you can proceed.",
        cancelText: "No",
        okText: "Okay, Open Settings",
      ) ?? false;

      if(val) {
        await await LocationPermissions().openAppSettings();
      }
      return;
    }

    routeTo("/change-location");
    return;
  }

  void updateProfile() {

    if(!hasChanged()) {
      return;
    }

    Map data = {
      "hideLocation": user.hideLocation,
      "hideProfile": user.hideProfile
    };

    UserService.postUpdateProfile(data).then((res) {
      Map userMap = res["data"];
      model.setUserMap(userMap);
      DataProvider().reloadPage("match");
    });
  }

  void deleteAccount() async {
    bool val = await WeMeetLoader.showBottomModalSheet(
      context,
      "Delete Your Account? 😨",
      content: "This will delete your account. Are you sure you want to proceed?",
      cancelText: "No, Just Kidding",
      okText: "Yes, Delete",
      okColor: AppColors.redColor,
      cancelColor: AppColors.color1
    );

    if(!val) {
      return;
    }

    WeMeetLoader.showLoadingModal(context);

    try {
      await AuthService.postSelfDelete();
      WeMeetToast.toast("Account deleted successfully", true);
      await Navigator.pushNamedAndRemoveUntil(context, "/register", (route) => false).then((e) async {
        await Future.delayed(Duration(milliseconds: 700));
        model.logOut();
      });
    } catch (e) {
      WeMeetToast.toast(kTranslateError(e), true);
    } finally {
      if(Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  bool hasChanged() {
    return (user.hideLocation != userData["hideLocation"] || user.hideProfile != userData["hideProfile"]);
  }

  Widget _tile({String title = "", String subtitle = "", VoidCallback callback, Widget trailing}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2.0)
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.0
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            height: 1.6,
            fontSize: 13.0
          ),
        ),
        trailing: trailing,
        onTap: callback,
      ),
    );
  }

  Widget buildBody() {
    return ListView(
      physics: ClampingScrollPhysics(),
      children: [
        _tile(
          title: "Change Location",
          subtitle: "Set your default location",
          trailing: Icon(Ionicons.chevron_forward),
          callback: gotoSetLocation
        ),
        SizedBox(height: 2.0),
        _tile(
          title: "Turn On/Off Location",
          subtitle: "Decide whether users see your location",
          trailing: Icon(
            !userData["hideLocation"] ? Icons.toggle_off : Icons.toggle_on,
            size: 30.0,
            color: userData["hideLocation"] ? AppColors.color1 : Colors.grey,
          ),
          callback: () {
            setState(() {
              userData["hideLocation"] = !userData["hideLocation"];              
            });
          }
        ),
        SizedBox(height: 10.0),
        _tile(
          title: "Change Password",
          subtitle: "Update your WeMeet login password",
          callback: () => routeTo("/change-password"),
          trailing: Icon(Ionicons.chevron_forward),
        ),
        SizedBox(height: 10.0),
        _tile(
          title: "Blocked Users",
          subtitle: "See all users that have been blocked",
          trailing: Icon(Ionicons.chevron_forward),
          callback: () => routeTo("/blocked-users")
        ),
        SizedBox(height: 2.0),
        _tile(
          title: "Hide My Profile",
          subtitle: "Lagos, Nigeria",
          trailing: Icon(
            !userData["hideProfile"] ? Icons.toggle_off : Icons.toggle_on,
            size: 30.0,
            color: userData["hideProfile"] ? AppColors.color1 : Colors.grey,
          ),
          callback: () {
            setState(() {
              userData["hideProfile"] = !userData["hideProfile"];              
            });
          }
        ),
        SizedBox(height: 30.0),
        GestureDetector(
          onTap: () async {
            Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false).then((e) async {
              
            });
            await Future.delayed(Duration(milliseconds: 700));
            model.logOut();
            print("******Logged out******");
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2.0)
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10.0,
              children: [
                Icon(Ionicons.exit_outline, color: Colors.redAccent,),
                Text("Logout", style: TextStyle(color: Colors.redAccent),)
              ],
            ),
          ),
        ),
        SizedBox(height: 30.0),
        WWideButton(
          title: "Delete Account",
          onTap: deleteAccount,
          color: Colors.redAccent,
        ),
      ],
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
    );
  }

  Future<bool> onWillPop() async {
    updateProfile();
    return true;
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        backgroundColor: Color(0xfff5f5f5),
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: buildBody(),
      ),
    ); 
  }
}