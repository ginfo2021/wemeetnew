import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:wemeet/models/song.dart';
import 'package:wemeet/utils/colors.dart';

class WSongCover extends StatelessWidget {

  final SongModel song;
  const WSongCover({Key key, this.song}) : super(key: key);

  Widget _playBtn() {
    return GestureDetector(
      child: Container(
        width: 25.0,
        height: 25.0,
        alignment: Alignment.center,
        child: Icon(Icons.play_arrow, color: AppColors.deepPurpleColor, size: 20.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 20.0),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      height: 120.0,
      width: 200.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.0)
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: song.artwork,
              placeholder: (context, _) => Container(
                color: Colors.black12,
                alignment: Alignment.center,
                child: Icon(
                  FeatherIcons.music,
                  color: Colors.white,
                  size: 60.0
                ),
              ),
              fit: BoxFit.cover,
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
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.7),
                    ],
                  )
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: TextStyle(
                            color: Colors.white
                          )
                        ),
                        Text(
                          song.artist,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.0
                          )
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: 10.0),
                  _playBtn()
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}