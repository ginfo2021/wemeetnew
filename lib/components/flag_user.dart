import 'package:flutter/material.dart';

class FlagUserModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    List items = [
      {
        "title": "Select an option",
        "value": null,
        "weight": FontWeight.bold,
        "color": Colors.black87
      },
      {
        "title": "Block User",
        "value": "block",
        "color": Colors.redAccent
      },
      {
        "title": "Report User",
        "value": "report",
        "color": Colors.redAccent,
      },
      {
        "title": "Cancel",
        "value": "cancel",
        "color": Colors.black54
      }
    ];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0)
      ),
      child: Container(
        width: 180.0,
        child: ListView.separated(
          itemBuilder: (context, index){
            Map item = items[index];
            return InkWell(
              onTap: item["value"] == null ? null : () {
                Navigator.pop(context, item["value"]);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                alignment: Alignment.center,
                child: Text(
                  items[index]["title"],
                  style: TextStyle(
                    color: item["color"],
                    fontWeight: item["weight"] ?? FontWeight.normal
                  ),
                ),
              )
            );
          },
          separatorBuilder: (context, index) => Divider(),
          itemCount: items.length,
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 15.0),
        ),
      ),
    );
  }
}