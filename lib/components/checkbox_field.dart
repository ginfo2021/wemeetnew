import 'package:flutter/material.dart';

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField(
      {Widget title,
      FormFieldSetter<bool> onSaved,
      FormFieldValidator<bool> validator,
      bool initialValue = false,
      Color errorColor,
      EdgeInsets padding,
      AutovalidateMode autovalidateMode = AutovalidateMode.disabled})
      : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            autovalidateMode: autovalidateMode,
            builder: (FormFieldState<bool> state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: state.value,
                        onChanged: state.didChange,
                      ),
                      Expanded(
                        child: title,
                      )
                    ],
                  ),
                  if(state.hasError) Builder(
                    builder: (BuildContext context) => Row(
                      children: [
                        SizedBox(width: 45.0),
                        Expanded(
                          child: Text(
                            state.errorText,
                            style: TextStyle(
                              color: errorColor ?? Theme.of(context).errorColor,
                              fontWeight: FontWeight.w300,
                              fontSize: 11.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              );
            });
}
