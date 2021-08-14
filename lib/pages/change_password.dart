import 'package:flutter/material.dart';

import 'package:wemeet/services/auth.dart';

import 'package:wemeet/components/text_field.dart';
import 'package:wemeet/components/loader.dart';
import 'package:wemeet/components/wide_button.dart';

import 'package:wemeet/utils/validators.dart';
import 'package:wemeet/utils/toast.dart';
import 'package:wemeet/utils/errors.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController currentPasswordC = TextEditingController();
  TextEditingController newPasswordC = TextEditingController();
  TextEditingController confirmPasswordC = TextEditingController();

  FocusNode currentPasswordNode = FocusNode();
  FocusNode newPasswordNode = FocusNode();
  FocusNode confirmPasswordNode = FocusNode();

  @override
  void initState() { 
    super.initState();
    
  }

  @override
  void dispose() { 
    currentPasswordC.dispose();
    newPasswordC.dispose();
    confirmPasswordC.dispose();
    currentPasswordNode.dispose();
    newPasswordNode.dispose();
    confirmPasswordNode.dispose();
    super.dispose();
  }

  void doSubmit() async {

    WeMeetLoader.showLoadingModal(context);

    Map data = {
      "oldPassword": currentPasswordC.text,
      "newPassword": newPasswordC.text,
      "confirmPassword": confirmPasswordC.text,
    };

    try {
      await AuthService.postChangedPassword(data);
      WeMeetToast.toast("Password changed successfully", true);
      formKey.currentState.reset();
    } catch (e) {
      WeMeetToast.toast(kTranslateError(e), true);
    } finally {
      if(Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  void submit() {
    FocusScope.of(context).requestFocus(FocusNode());
    final form = formKey.currentState;
    if(form.validate()) {
      form.save();
      doSubmit();
    }
  }

  Widget buildForm() {
    return Form(
      key: formKey,
      child: ListView(
        physics: ClampingScrollPhysics(),
        children: [
          Text(
            "Update Password",
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w500
            ),
          ),
          SizedBox(height: 20.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0)
            ),
            child: Column(
              children: [
                SizedBox(height: 20.0),
                WeMeetTextField(
                  controller: currentPasswordC,
                  focusNode: currentPasswordNode,
                  // helperText: "Current Password",
                  hintText: "Current Password",
                  validator: PasswordValidator.validate,
                  isPassword: true,
                  showPasswordToggle: true,
                  borderColor: Colors.black12,
                  inputAction: TextInputAction.next,
                  onFieldSubmitted: (val) {
                    FocusScope.of(context).requestFocus(newPasswordNode);
                  },
                ),
                SizedBox(height: 20.0),
                WeMeetTextField(
                  controller: newPasswordC,
                  focusNode: newPasswordNode,
                  // helperText: "New Password",
                  hintText: "New Password",
                  validator: PasswordValidator.validate,
                  isPassword: true,
                  showPasswordToggle: true,
                  inputAction: TextInputAction.next,
                  onFieldSubmitted: (val) {
                    FocusScope.of(context).requestFocus(confirmPasswordNode);
                  },
                  borderColor: Colors.black12,
                ),
                SizedBox(height: 20.0),
                WeMeetTextField(
                  controller: confirmPasswordC,
                  focusNode: confirmPasswordNode,
                  hintText: "Confirm your new password",
                  validator: (val) => ConfirmPasswordValidator.validate(val, newPasswordC.text),
                  isPassword: true,
                  showPasswordToggle: true,
                  inputAction: TextInputAction.go,
                  onFieldSubmitted: (val) {
                    submit();
                  },
                  borderColor: Colors.black12,
                ),
                SizedBox(height: 60.0)
              ],
            ),
          ),
          SizedBox(height: 30.0),
          WWideButton(
            title: "Update",
            onTap: submit,
          ),
        ],
        padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      appBar: AppBar(
        title: Text("Change Password"),
      ),
      body: buildForm(),
    );
  }
}