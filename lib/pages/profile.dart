import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/user.dart';
import 'package:wemeet/utils/colors.dart';
import 'package:wemeet/utils/svg_content.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  AppModel model;
  UserModel user;

  Map genders = {"MALE": "Guy", "FEMALE": "Girl"};

  Map<String, String> prefs = {
    "MALE": "Guys",
    "FEMALE": "Girls",
    "None": "I'd rather not say"
  };

  Map<String, String> eStatuses = {
    "WORKING": "Employed",
    "SELF_EMPLOYED": "Self-Employed",
    "UNEMPLOYED": "Unemployed",
    "STUDENT": "Student"
  };

  void routeTo(String page) {
    Navigator.pushNamed(context, page);
  }

  Widget _picture(String avi, [double radius = 50.0, double right = 0.0]) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      margin: EdgeInsets.only(right: right),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1.0)
      ),
      child: CachedNetworkImage(
        imageUrl: avi,
        placeholder: (context, p) => Container(
          color: AppColors.deepPurpleColor.withOpacity(0.02)
        ),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _tile(String title, Widget child, {String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey
                ),
              )
            ),
            if (subtitle != null) Container(
              margin: EdgeInsets.only(left: 10.0),
              child: Text(
                subtitle
              ),
            )
          ],
        ),
        SizedBox(height: 10.0),
        child
      ],
    );
  }

  Widget _buildAddImgs() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Additional Photos"
          ),
          SizedBox(height: 10.0),
          SizedBox(
            height: 100.0,
            child: ListView.builder(
              itemBuilder: (context, index) => _picture(user.additionalImages[index], 50.0, 20.0),
              itemCount: user.additionalImages.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 30.0),
            Center(
              child: _picture(user.profileImage),
              
            ),
            SizedBox(height: 10.0),
            Text(
              "${user.fullName}, ${user.ageF}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18.0
              ),
            ),
            SizedBox(height: 20.0),
            _buildAddImgs(),
            SizedBox(height: 30.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => routeTo("/complete-profile"),
                    child: Text(
                      "Edit Photos",
                      style: TextStyle(
                        color: AppColors.color1,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(AppColors.color1.withOpacity(0.2)),
                      elevation: MaterialStateProperty.all(0.0)
                    ),
                  ),
                ),
                SizedBox(width: 15.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => routeTo("/preference"),
                    child: Text(
                      "Edit Preference",
                      style: TextStyle(
                        color: AppColors.color1,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(AppColors.orangeColor.withOpacity(0.2)),
                      elevation: MaterialStateProperty.all(0.0)
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 30.0),
            _tile(
              "Bio",
              Text(
                "${user.bio}"
              )
            ),
            SizedBox(height: 20.0),
            _tile(
              "You're a",
              Text(
                "${genders[user.gender] ?? "Not set"}"
              )
            ),
            SizedBox(height: 30.0),
            _tile(
              "You are interested in",
              Text(
                "${user.genderPreference.map((e) => prefs[e]).join(", ")}"
              )
            ),
            SizedBox(height: 30.0),
            _tile(
              "Age Range",
              Text(
                "${user.minAge} - ${user.maxAge}"
              )
            ),
            SizedBox(height: 30.0),
            _tile(
              "Distance(km)",
              Text(
                "${user.swipeRadius}km"
              )
            ),
            SizedBox(height: 30.0),
            _tile(
              "You are currently",
              Text(
                "${eStatuses[user.workStatus] ?? "Not set"}"
              )
            ),
            SizedBox(height: 30.0),
            _tile(
              "Date of Birth",
              Text(
                "${user.dobF}"
              )
            ),
            SizedBox(height: 30.0),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return ScopedModelDescendant<AppModel> (
      builder: (context, child, m) {
        model = m;
        user = m.user;

        return Scaffold(
          appBar: AppBar(
            title: Text("Profile"),
            actions: [
              IconButton(
                icon: Container(
                  width: 25.0,
                  height: 25.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.color1.withOpacity(0.1),
                    shape: BoxShape.circle
                  ),
                  child: SvgPicture.string(
                    WemeetSvgContent.heartY,
                    color: AppColors.color1,
                    width: 15.0,
                    height: 15.0,
                  ),
                ),
                onPressed: () => routeTo("/matches")
              ),
              IconButton(
                icon: Icon(Ionicons.cog_outline),
                onPressed: () => routeTo("/settings")
              )
            ],
          ),
          body: buildBody(),
        );
      },
    );
  }
}