import 'package:flutter/material.dart';

import 'package:wemeet/services/audio.dart';
import 'package:wemeet/utils/colors.dart';
import 'package:wemeet/utils/converters.dart';

class ChatPlayer extends StatefulWidget {

  final String url;

  const ChatPlayer({Key key, @required this.url}) : super(key: key);

  @override
  _ChatPlayerState createState() => _ChatPlayerState();
}

class _ChatPlayerState extends State<ChatPlayer> {

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

  Widget _playBtn(String mode, List<String> controls, String cItem) {

    IconData icon = Icons.play_arrow;
    VoidCallback callback = () => _audioService.playFromUrl(widget.url);

    if(cItem != widget.url) {
      if(!controls.contains("completed")) {
        callback = _audioService.play;
      }

      if(controls.contains("playing") || controls.contains("buffering")) {
        callback = _audioService.pause;
        icon = Icons.pause;
      }

      if(controls.contains("none")) {
        callback = () => _audioService.playFromUrl(widget.url);
        icon = Icons.play_arrow;
      }

    } else {

      if(controls.contains("playing") || controls.contains("buffering")) {
        callback = _audioService.pause;
        icon = Icons.pause;
      }

      if(controls.contains("completed")) {
        callback = () => _audioService.playFromUrl(widget.url);
        icon = Icons.play_arrow;
      }
    }

    return _iconBtn(
      icon,
      true,
      callback
    );
  }

  Widget _buildPlayer(String mode, List<String> controls, String cItem) {

    if(!isMp3(widget.url)) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        margin: EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
          color: AppColors.color1.withOpacity(0.2),
          borderRadius: BorderRadius.circular(5.0)
        ),
        child: Text(
          "Bad audio... Please resend",
          style: TextStyle(
            fontStyle: FontStyle.italic
          ),
        ),
      );
    } 

    return Container(
      width: 250.0,
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      margin: EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: AppColors.color1,
        borderRadius: BorderRadius.circular(5.0)
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Shared Audio",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white
              ),
            ),
          ),
          _playBtn(mode, controls, cItem),
        ],
      ),
    );


    /*return Container(
      margin: EdgeInsets.only(
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
                val.contains("playing") ? _audioService.pause : () => _audioService.playSong(song) 
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
    );*/
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<String>(
        stream: _audioService.playerModeStream,
        initialData: "none",
        builder: (context, snapshot) {

          if(!snapshot.hasData) {
            return SizedBox();
          }

          final mode = snapshot.data;

          return StreamBuilder<List<String>>(
            stream: _audioService.controlsStream,
            initialData: ["none"],
            builder: (context, snapshot) {
              if(!snapshot.hasData) {
                return SizedBox();
              }

              final String cItem = _audioService.currentUrl;

              return _buildPlayer(mode, snapshot.data, cItem);
            }
          );
        }
      ),
    );
  }
}