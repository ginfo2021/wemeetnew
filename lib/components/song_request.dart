import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';

import 'package:wemeet/services/music.dart';

import 'package:wemeet/utils/colors.dart';
import 'package:wemeet/utils/errors.dart';
import 'package:wemeet/utils/toast.dart';

class SongRequestDialog extends StatefulWidget {
  @override
  _SongRequestDialogState createState() => _SongRequestDialogState();
}

class _SongRequestDialogState extends State<SongRequestDialog> {

  String description;

  void sendRequest() async {

    if(description == null || description.isEmpty) {
      return;
    }

    await Navigator.pop(context);

    Map data = {
      "description": description,
      "id": 0
    };

    try {
      var res  = await MusicService.postRequest(data);
      WeMeetToast.toast(res["message"] ?? "Song request sent");
    } catch (e) {
      WeMeetToast.toast(kTranslateError(e), true);
    } 

  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0)
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Request a Song",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700
              )
            ),
            SizedBox(height: 20.0),
            Text(
              "Tell us the song you'd like to add and we'd add it to tomorrow's playlist."
            ),
            SizedBox(height: 20.0),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black12)
                )
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(FeatherIcons.music, color: AppColors.color1.withOpacity(0.3)),
                  SizedBox(width: 15.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Song Description",
                          style: TextStyle(
                            fontSize: 12.0
                          ),
                        ),
                        SizedBox(height: 5.0),
                        TextField(
                          autocorrect: false,
                          style: TextStyle(
                            fontSize: 14.0
                          ),
                          decoration: InputDecoration.collapsed(
                            hintText: "Song Description",
                            border: InputBorder.none
                          ),
                          onChanged: (val) {
                            setState((){
                              description = val;
                            });
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 50.0),
            Wrap(
              alignment: WrapAlignment.end,
              children: [
                TextButton(
                  onPressed: (){ Navigator.pop(context);},
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: sendRequest,
                  child: Text(
                    "Send Song Request", 
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.color1
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}