import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';

import 'package:wemeet/components/icon_box.dart';

import 'package:wemeet/utils/colors.dart';

class NotFoundPage extends StatelessWidget {

  void _back(BuildContext context, [bool canPop = false]) {
    if(canPop) {
      Navigator.of(context).pop();
    } else {
      Navigator.pushNamedAndRemoveUntil(context, "/start", (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool canPop = Navigator.of(context).canPop();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.color1
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: 20.0,
              top: kToolbarHeight,
              child: WIconBox(
                FeatherIcons.x,
                onTap: () => _back(context, canPop),
                bgColor: Colors.white60,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FeatherIcons.alertTriangle, size: 90.0, color: AppColors.color4),
                  SizedBox(height: 20.0),
                  Text(
                    "Congratulations 👍",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    "You managed to break something",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    "What you are looking for does not exist... yet",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}