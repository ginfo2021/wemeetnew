import 'package:flutter/material.dart';
import 'package:wemeet/utils/colors.dart';

class WErrorComponent extends StatelessWidget {

  final IconData icon;
  final String text;
  final String buttonText;
  final VoidCallback callback;
  const WErrorComponent({Key key, @required this.text, this.icon, this.callback, this.buttonText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if(icon != null) Container(
            margin: EdgeInsets.only(top: 20.0),
            child: Icon(
              icon,
              color: AppColors.deepPurpleColor,
              size: 90.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(text),
          ),
          callback != null ? TextButton(
            onPressed: callback, 
            child: Text(buttonText ?? "Retry")
          ) : null
        ].where((element) => element != null).toList(),
      ),
    );
  }
}