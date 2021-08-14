import 'package:flutter/material.dart';
import 'package:wemeet/utils/colors.dart';

class ReportUserDialog extends StatefulWidget {
  @override
  _ReportUserDialogState createState() => _ReportUserDialogState();
}

class _ReportUserDialogState extends State<ReportUserDialog> {

  String reason = "Abusive";
  List<String> reasons = ["Abusive", "Fake Profile", "Harrasement", "Others"];

  Widget padIt(Widget child) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 5.0),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0)
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            padIt(Text(
              "Report User",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19.0
              ),
            )),
            padIt(Text(
              "Why are you reporting this user?",
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.black54
              ),
            )),
            ...reasons.map((i) => RadioListTile(
              groupValue: reason,
              value: i,
              activeColor: AppColors.redColor,
              title: Text(i),
              dense: true,
              onChanged: ((e) {
                setState(() {
                  reason = e;                  
                });
              }),
            )).toList(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.black45,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: (){
                    Navigator.pop(context, reason);
                  },
                  child: Text(
                    "Submit Report",
                    style: TextStyle(
                      color: Colors.redAccent,
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