import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:wemeet/utils/colors.dart';
import 'package:wemeet/utils/svg_content.dart';

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  int _currentIndex = 0;

  PageController _controller = PageController(initialPage: 0);
  MediaQueryData mQuery;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildItem(Map item, int index) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.string(
            item["image"],
            height: 150.0,
          ),
          SizedBox(height: 30.0),
          Text(
            item["title"],
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20.0),
          ),
          Text(
            item["subtitle"],
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20.0),
          )
        ],
      ),
    );
  }

  Widget buildIndicator() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(bottom: mQuery.padding.bottom + 150.0),
        child: Wrap(
          spacing: 10.0,
          children: List.generate(3, (index) {
            bool active = index == _currentIndex;
            return AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: 10.0,
                height: 10.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.color1.withOpacity(active ? 1.0 : 0.1)));
          }),
        ),
      ),
    );
  }

  Widget buildArrow() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(bottom: mQuery.padding.bottom + 60.0),
        child: (_currentIndex == 2)
            ? Container(
                width: mQuery.size.width * 0.90,
                height: 50.0,
                constraints: BoxConstraints(maxWidth: 500.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, "/register");
                  },
                  child: Text(
                    "Get Started",
                    style: TextStyle(color: AppColors.color3),
                  ),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(AppColors.color1),
                      elevation: MaterialStateProperty.all(0.0),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)))),
                ),
              )
            : InkWell(
                onTap: () {
                  _controller.animateToPage(_currentIndex + 1,
                      duration: Duration(milliseconds: 200),
                      curve: Curves.linear);
                },
                child: SvgPicture.string(
                  WemeetSvgContent.arrow,
                  width: 80.0,
                ),
              ),
      ),
    );
  }

  Widget buildBody() {
    List<Map> items = [
      {
        "image": WemeetSvgContent.onboarding1,
        "title": "Find the person",
        "subtitle": "made just for you"
      },
      {
        "image": WemeetSvgContent.onboarding2,
        "title": "Entertain friends",
        "subtitle": "with our daily playlists"
      },
      {
        "image": Image.network(
            "https://media.giphy.com/media/hKdz27BIb3k7WsJ1Eo/giphy.gif"),
        "title": "Real-time chatting",
        "subtitle": "to keep you connected"
      }
    ];

    return Container(
      child: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              itemBuilder: (context, index) => buildItem(items[index], index),
              itemCount: items.length,
              controller: _controller,
              onPageChanged: (val) {
                setState(() {
                  _currentIndex = val;
                });
              },
              physics: ClampingScrollPhysics(),
            ),
          ),
          buildIndicator(),
          buildArrow(),
          if (_currentIndex > 0)
            Positioned(
              left: 10.0,
              top: kToolbarHeight - 10.0,
              child: IconButton(
                  onPressed: () {
                    _controller.animateToPage(_currentIndex - 1,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.linear);
                  },
                  icon: Icon(FeatherIcons.chevronLeft,
                      color: Colors.grey.withOpacity(0.5), size: 30.0)),
            )
        ].where((e) => e != null).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    mQuery = MediaQuery.of(context);
    return Scaffold(
      body: buildBody(),
    );
  }
}
