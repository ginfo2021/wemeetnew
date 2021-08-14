import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/user.dart';

import 'package:wemeet/services/user.dart';

import 'package:wemeet/components/loader.dart';
import 'package:wemeet/components/wide_button.dart';
import 'package:wemeet/components/picture_uploader.dart';

import 'package:wemeet/utils/svg_content.dart';
import 'package:wemeet/utils/toast.dart';
import 'package:wemeet/utils/errors.dart';

class CompleteProfilePage extends StatefulWidget {

  final AppModel model;
  const CompleteProfilePage({Key key, this.model}) : super(key: key);

  @override
  _CompleteProfilePageState createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {

  AppModel model;
  UserModel user;

  List<String> images = List.generate(5, (index) => null);

  @override
  void initState() { 
    super.initState();
    model = widget.model;
    user = model.user; 

    populateImages();
  }

  void updateImages() async {

    if(user.profileImage == null || user.profileImage.isEmpty) {
      WeMeetToast.toast("Please upload a profile photo");
      return;
    }

    bool canPop = Navigator.of(context).canPop();

    WeMeetLoader.showLoadingModal(context);

    Map data = {
      "profileImage": user.profileImage,
      "additionalImages": images.where((e) => e != null).toList()
    };

    try {

      var res = await UserService.postUpdateProfileImages(data);
      print(res);
      model.addUserMap(data);

      WeMeetToast.toast(res["message"] ?? "Successfully saved user profile", true);

      // if can't pop and profile image is not set
      if(!canPop) {
        Navigator.of(context).pushNamedAndRemoveUntil("/home", (route) => false);
        return;
      }

      Navigator.pop(context);
      
    } catch (e) {
      print(e);
      WeMeetToast.toast(kTranslateError(e), true);
    } finally {
      if(Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  void populateImages() {
    for (var i = 0; i < user.additionalImages.length; i++) {
      images[i] = user.additionalImages[i];
    }
  }

  Widget _tile(String title, Widget child) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey
            ),
          ),
          SizedBox(height: 10.0),
          child
        ],
      ),
    );
  }

  Widget buildAddImage() {
    return _tile(
      "Additional Images (Optional)",
      Container(
        height: 100.0,
        child: ListView(
          children: List.generate(5, (index){
            return PictureUploader(
              imageUrl: images[index],
              type: "ADDITIONAL_IMAGE",
              right: 15.0,
              onDone: (val){
                setState(() {
                  images[index] = val;                  
                });
              },
            );
          }),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
        ),
      )
    );
  }

  Widget buildBody() {
    return Container(
      child: ListView(
        children: [
          SvgPicture.string(
            WemeetSvgContent.profile,
            alignment: Alignment.centerLeft,
          ),
          SizedBox(height: 20.0),
          Text(
            "Add picture",
            style: TextStyle(
              fontWeight: FontWeight.w500 ,
              fontSize: 17.0
            ),
          ),
          SizedBox(height: 30.0),
          _tile(
            "Profile Photo",
            PictureUploader(
              imageUrl: user?.profileImage,
              type: "PROFILE_IMAGE",
              onDone: (val){
                setState(() {
                  user.profileImage = val;                  
                });
              },
            )
          ),
          SizedBox(height: 30.0),
          buildAddImage(),
          SizedBox(height: 40.0),
          WWideButton(
            title: "Done",
            onTap: updateImages,
          )
        ],
        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        physics: ClampingScrollPhysics(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: buildBody(),
    );
  }
}