import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WeMeetTextField extends StatefulWidget {

  final String helperText;
  final String subHelperText;
  final String hintText;
  final bool isPassword;
  final TextEditingController controller;
  final FocusNode focusNode;
  final AutovalidateMode autovalidateMode;
  final TextInputAction inputAction;
  final TextInputType keyboardType;
  final Function(String) onFieldSubmitted;
  final Function(String) validator;
  final Function onEditingComplete;
  final int maxLines;
  final Function(String) onChanged;
  final int maxLength;
  final Widget prefixIcon;
  final Widget suffixIcon;
  final Function onTap;
  final VoidCallback onFieldTapped;
  final bool autocorrect;
  final List<TextInputFormatter> inputFormatters;
  final Iterable<String> autofillHints;
  final Color borderColor;
  final Color hintColor;
  final Color helperColor;
  final Color subHelperColor;
  final Color textColor;
  final Color errorColor;
  final bool showPasswordToggle;
  final bool enabled;

  WeMeetTextField({
    Key key,
    this.helperText,
    this.subHelperText,
    this.hintText,
    this.controller,
    this.focusNode,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.inputAction,
    this.isPassword = false,
    this.keyboardType,
    this.maxLength, 
    this.maxLines = 1,
    this.onChanged,
    this.onEditingComplete, 
    this.onFieldSubmitted,
    this.onTap,
    this.onFieldTapped,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.autocorrect = false,
    this.inputFormatters,
    this.autofillHints,
    this.borderColor = Colors.black45,
    this.hintColor = Colors.black54,
    this.helperColor = Colors.black87,
    this.textColor = Colors.black87,
    this.subHelperColor = Colors.black45,
    this.errorColor = Colors.red,
    this.showPasswordToggle = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  _WeMeetTextFieldState createState() => _WeMeetTextFieldState();
}

class _WeMeetTextFieldState extends State<WeMeetTextField> {

  bool isPassword = false;

  @override
  void initState() { 
    super.initState();
    
    isPassword = widget.isPassword; 
  }

  Widget buildSuffix() {
    if(widget.suffixIcon != null && !widget.isPassword) {
      return widget.suffixIcon;
    }

    if(widget.showPasswordToggle) {
      return GestureDetector(
        onTap: () {
          setState(() {
            isPassword = !isPassword;            
          });
        },
        child: Icon(
          isPassword ? Icons.visibility : Icons.visibility_off,
          color: Colors.grey,
        ),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widget.helperText != null ? Padding(
            padding: EdgeInsets.symmetric(vertical: 2.0),
            child: Wrap(
              spacing: 5.0,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                Text(
                  widget.helperText,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: widget.helperColor
                  )
                ),
                Text(
                  "${widget.subHelperText ?? ""}",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 11.0,
                    color: Colors.black45,
                  ),
                )
              ].where((e) => e != null).toList(),
            ),
          ) : null,
          GestureDetector(
            onTap: widget.onFieldTapped,
            child: TextFormField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              obscureText: isPassword,
              autovalidateMode: widget.autovalidateMode,
              textInputAction: widget.inputAction,
              keyboardType: widget.keyboardType,
              onFieldSubmitted: widget.onFieldSubmitted,
              validator: widget.validator,
              onEditingComplete: widget.onEditingComplete,
              onTap: widget.onTap,
              maxLines: widget.maxLines,
              onChanged: widget.onChanged,
              maxLength: widget.maxLength,
              inputFormatters: widget.inputFormatters,
              autocorrect: widget.autocorrect,
              autofillHints: widget.autofillHints,
              enabled: widget.enabled,
              style: TextStyle(
                color: widget.textColor
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: widget.hintColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 14.0,
                ),
                errorStyle: TextStyle(
                  color: widget.errorColor,
                  fontWeight: FontWeight.w300,
                  fontSize: 11.0,
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: widget.borderColor 
                  )
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.borderColor)
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.borderColor)
                ),
                suffixIcon: buildSuffix(),
                prefixIcon: widget.prefixIcon,
              ),
            ),
          ),
        ].where((e) => e != null).toList(),
      ),
    );
  }
}