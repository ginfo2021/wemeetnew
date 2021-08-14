import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:strings/strings.dart' as strings;

import 'package:wemeet/models/user.dart';

import 'package:wemeet/utils/colors.dart';
import 'package:wemeet/utils/svg_content.dart';

class UserDetailsPage extends StatelessWidget {

  final UserModel user;
  final String tag;
  final ValueChanged<bool> onSwipe;

  const UserDetailsPage({Key key, @required this.user, @required this.tag, this.onSwipe}) : super(key: key);

  static BuildContext ctx;

  Widget _swipeBtn(String icon, [bool right = false]) {
    return InkWell(
      onTap: () {
        if(onSwipe == null) return;
        onSwipe(right);
        Navigator.pop(ctx);
      },
      child: Container(
        width: 50.0,
        height: 50.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xfffcf5e9)
        ),
        child: SvgPicture.string(
          icon,
          color: AppColors.orangeColor
        ),
      ),
    );
  }

  Widget buildTop() {
    return Container(
      height: MediaQuery.of(ctx).size.height * 0.65,
      constraints: BoxConstraints(
        maxHeight: 600.0
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 20.0,
            top: 0.0,
            right: 0.0,
            left: 0.0,
            child: Hero(
              tag: "${tag}",
              child: CachedNetworkImage(
                imageUrl: user.profileImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            left: 40.0,
            bottom: 0.0,
            child: _swipeBtn(WemeetSvgContent.cancel, false),
          ),
          Positioned(
            right: 40.0,
            bottom: 0.0,
            child: _swipeBtn(WemeetSvgContent.heartY, true),
          ),
          Positioned(
            top: kToolbarHeight - 25.0,
            child: IconButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              icon: Icon(Icons.chevron_left, color: Colors.white, size: 40.0,)
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
    return Container(
      child: Column(
        children: [
          buildTop(),
          Center(
            child: Column(
              children: [
                Text(
                  "${user.firstName}, ${user.age}",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.0
                  ),
                ),
                SizedBox(height: 7.0,),
                Text(
                  "${user.workStatus.toLowerCase().split("_").map((e) => strings.capitalize(e)).join(" ")}",
                  style: TextStyle(
                    fontSize: 13
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  "${user.distanceInKm ?? 1} Km Away",
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.0),
          if(user.additionalImages.isNotEmpty) SizedBox(
            height: 120.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                String img = user.additionalImages[index];
                return Container(
                  width: 100.0,
                  height: 50.0,
                  margin: EdgeInsets.only(right: 10.0),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.0)
                  ),
                  child: CachedNetworkImage(
                    imageUrl: img,
                    fit: BoxFit.cover,
                  ),
                );
              },
              itemCount: user.additionalImages.length,
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return Scaffold(
      body: buildBody(),
    );
  }
}