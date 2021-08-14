import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wemeet/components/wide_button.dart';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/user.dart';

import 'package:wemeet/utils/colors.dart';
import 'package:wemeet/utils/svg_content.dart';

class MatchFoundPage extends StatelessWidget {

  final UserModel match;

  const MatchFoundPage({Key key, this.match}) : super(key: key);

  static double dWidth = 400.0;

  void addMatch(AppModel model) {
    Map mL = model.matchList ?? {};
    mL["${match.id}"] = {"name": match.fullName, "image": match.profileImage ?? "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png"};
    model.setMatchList(mL);
  }

  Widget buildUserPic(String url, [double radius = 180.0]) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.color1, width: 3.0)
      ),
      child: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    dWidth = MediaQuery.of(context).size.width;
    final btnWidth = 65.0;

    return ScopedModelDescendant<AppModel> (
      builder: (context, child, model) {
         return Scaffold(
           body: Container(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                 SizedBox(height: kToolbarHeight + 50.0),
                 Text(
                  'We have a match!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 30.0),
                Container(
                  height: 360.0,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: EdgeInsets.only(
                            left: btnWidth * 2,
                            top: btnWidth / 2
                          ),
                          child: buildUserPic(
                            model.user?.profileImage,
                          ),
                          // child: Text("${model.user?.profileImage}"),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: EdgeInsets.only(
                            right: btnWidth * 2,
                            bottom: btnWidth / 2
                          ),
                          child: buildUserPic(
                            match.profileImage ?? "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png",
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: btnWidth,
                          height: btnWidth,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xfff0e5fe),
                          ),
                          child: SvgPicture.string(
                            WemeetSvgContent.heartY,
                            color: AppColors.color1,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Spacer(),
                WWideButton(
                  title: "Work My Magic",
                  onTap: (){
                    addMatch(model);
                    Navigator.pop(context, true);
                  },
                ),
                SizedBox(height: 20.0,),
                WWideButton(
                  title: "Talk Later... Keep Swiping",
                  onTap: (){
                    addMatch(model);
                    Navigator.pop(context, false);
                  },
                  color: Color(0xfff0e5fe),
                  textColor: Colors.black87,
                ),
                SizedBox(height: 80.0,),
               ],
             ),
           ),
        );
      },
    );
  }
}