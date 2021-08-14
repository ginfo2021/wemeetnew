import 'package:flutter/material.dart';

class WSearchField extends StatelessWidget {

  final Function(String) onChanged;
  final Function(String) onSubmit;
  final String hintText;
  const WSearchField({Key key, this.hintText, this.onChanged, this.onSubmit}) : super(key: key);

  static InputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: BorderSide(color: Colors.white, width: 0.0)
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      onSubmitted: onSubmit,
      autocorrect: false,
      decoration: InputDecoration(
        hintText: hintText ?? "Search",
        prefixIcon: Icon(Icons.search, color: Colors.black45),
        border: border,
        focusedBorder: border,
        disabledBorder: border,
        enabledBorder: border,
        fillColor: Color(0xFFF5F5F5),
        filled: true,
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0)
      ),
    );
  }
}