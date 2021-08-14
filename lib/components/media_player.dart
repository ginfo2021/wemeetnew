import 'package:flutter/material.dart';
import 'package:wemeet/models/song.dart';

import 'package:wemeet/services/audio.dart';
import 'package:wemeet/utils/colors.dart';

class WMEdiaPlayer extends StatefulWidget {

  final double right;
  final double left;
  final double top;
  final double bottom;
  final bool occupy;

  const WMEdiaPlayer({Key key, this.right = 20.0, this.left = 20.0, this.top = 20.0, this.bottom = 20.0, this.occupy = false}) : super(key: key);

  @override
  _WMEdiaPlayerState createState() => _WMEdiaPlayerState();
}

class _WMEdiaPlayerState extends State<WMEdiaPlayer> {

  WeMeetAudioService _audioService = WeMeetAudioService();

  @override
  void initState() { 
    super.initState();
  }

  Widget _iconBtn(IconData icon, bool show, VoidCallback callback) {
    return GestureDetector(
      onTap: show? callback : null,
      child: Icon(
        icon,
        size: 29.0,
        color: show ? Colors.white : Colors.transparent
      ),
    );
  }

  Widget _buildPlayer(List<String> val, SongModel song) {

    if(val.isEmpty || (val.length == 1 && val.contains("none")) || song == null) {
      return SizedBox(height: widget.occupy ? 100 : 0.0,);
    }

    return Container(
      margin: EdgeInsets.only(
        top: widget.top,
        left: widget.left,
        right: widget.right,
        bottom: widget.bottom
      ),
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: AppColors.color1,
        borderRadius: BorderRadius.circular(5.0)
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white
                  ),
                ),
                Text(
                  song.artist,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.white
                  ),
                )
              ],
            ),
          ),
          Wrap(
            spacing: 10.0,
            children: [
              _iconBtn(
                Icons.fast_rewind,
                _audioService.canPrevious,
                _audioService.skipToPrevious
              ),
              _iconBtn(
                val.contains("paused") ? Icons.play_arrow : Icons.pause,
                (val.contains("paused") || val.contains("playing")),
                (val.contains("playing") && !val.contains("paused")) ? _audioService.pause : () => _audioService.playSong(song) 
              ),
              _iconBtn(
                Icons.fast_forward,
                _audioService.canNext,
                _audioService.skipToNext
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<String>(
        stream: _audioService.playerModeStream,
        initialData: "none",
        builder: (context, snapshot) {

          if(!snapshot.hasData) {
            return SizedBox(height: widget.occupy ? 100 : 0.0,);
          }

          if(snapshot.data != "playlist") {
            return SizedBox(height: widget.occupy ? 100 : 0.0,);
          }

          return StreamBuilder<List<String>>(
            stream: _audioService.controlsStream,
            initialData: ["none"],
            builder: (context, snapshot) {
              print(snapshot.data);
              if(!snapshot.hasData) {
                return SizedBox();
              }

              final SongModel cItem = _audioService.currentMedia;

              return _buildPlayer(snapshot.data, cItem);
            }
          );
        }
      ),
    );
  }
}