import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:wemeet/models/song.dart';
import 'package:wemeet/utils/colors.dart';

import 'package:wemeet/services/audio.dart';

class WPlaylisItem extends StatelessWidget {

  final SongModel song;
  const WPlaylisItem({Key key, this.song}) : super(key: key);

  static WeMeetAudioService _audio = WeMeetAudioService();
  

  Widget _playBtn(SongModel cItem, List controls) {

    IconData icon = Icons.play_arrow;
    Color color = AppColors.deepPurpleColor;
    VoidCallback callback = () => _audio.playSong(song);

    if(cItem == song) {
      if(controls.contains("playing") && !controls.contains("paused")) {
        icon = Icons.pause;
        color = AppColors.deepPurpleColor.withOpacity(0.3);
        callback = _audio.pause;
      }
    } 

    // if(isPlaying) {
    //   icon = Icons.pause;
    //   color = AppColors.deepPurpleColor.withOpacity(0.3);
    // }

    return IconButton(
      onPressed: callback,
      icon: Icon(icon, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    // WeMeetAudioService _audio = WeMeetAudioService();
    return StreamBuilder<List<String>>(
      stream: _audio.controlsStream,
      initialData: ["none"],
      builder: (context, snapshot) {
        final SongModel cItem = _audio.currentMedia; 
        final controls = snapshot.data ?? ["none"];

        return Container(
          child: ListTile(
            leading: Container(
              width: 50.0,
              alignment: Alignment.center,
              child: Icon(FeatherIcons.music, color: Colors.black87),
            ),
            title: Text(
              song.title
            ),
            subtitle: Text(
              song.artist,
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
                height: 2.0
              ),
            ),
            trailing: _playBtn(cItem, controls),
          ),
        );
      },



      /*child: Container(
        child: ListTile(
          leading: Container(
            width: 50.0,
            alignment: Alignment.center,
            child: Icon(FeatherIcons.music, color: Colors.black87),
          ),
          title: Text(
            song.title
          ),
          subtitle: Text(
            song.artist,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey,
              height: 2.0
            ),
          ),
          trailing: _playBtn(),
        ),
      ),*/
    );
  }
}