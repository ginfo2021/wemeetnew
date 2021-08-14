import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class WKeyboardDismissable extends StatelessWidget {

  final Widget child;
  final bool android;
  const WKeyboardDismissable({Key key, @required this.child, this.android = false}) : super(key: key);

  bool _isVisible(bool visible) {
    if(Platform.isAndroid && !android) {
      return false;
    }

    return visible;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Container(
          child: Stack(
            children: [
              Positioned.fill(child: child, top: _isVisible(isKeyboardVisible) ? -10.0 : 0.0),
              _isVisible(isKeyboardVisible) ? Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                  color: Color(0xfff8f8f8),
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    child: Text(
                      "Done",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey
                      ),
                    ),
                    onTap: (){
                      FocusScope.of(context).requestFocus(FocusNode());
                    }
                  ),
                ),
              ) : null
            ].where((e) => e != null).toList(),
          ),
        );
      }
    );
  }
}