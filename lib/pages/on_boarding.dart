import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wemeet/utils/colors.dart';
import 'package:wemeet/utils/svg_content.dart';

void main() => runApp(VideoApp());

class VideoApp extends StatefulWidget {
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;
  int _currentIndex = 0;
  MediaQueryData mQuery;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.network('https://wemeet.africa/wemeet.mp4')
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.

            setState(() {
              _controller.play();
              _controller.setLooping(true);
            });
          });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
          body: Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : Container(),
          ),
          floatingActionButton: Container(
            height: 50.0,
            width: 150.0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/register");
              },
              child: Text(
                "Get Started",
                style: TextStyle(color: AppColors.color3, fontSize: 16),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              backgroundColor: AppColors.color1,
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
