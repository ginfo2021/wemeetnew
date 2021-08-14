import 'package:flutter/material.dart';
import 'package:wemeet/utils/colors.dart';

class WIconBox extends StatelessWidget {

  final double radius;
  final Color bgColor;
  final double iconSize;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double right;
  final double left;

  const WIconBox(this.icon, {Key key, this.radius = 30.0, this.bgColor, this.iconSize = 15.0, this.color, this.right = 0.0, this.left = 0.0, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.only(
          left: left,
          right: right
        ),
        width: radius,
        height: radius,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor ?? AppColors.color2,
          borderRadius: BorderRadius.circular(10.0)
        ),
        child: Icon(icon, size: iconSize, color: color ?? Colors.white),
      ),
    );
  }
}