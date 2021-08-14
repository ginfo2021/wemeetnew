import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wemeet/components/loader.dart';

import 'package:wemeet/components/text_field.dart';
import 'package:wemeet/components/wide_button.dart';
import 'package:wemeet/services/auth.dart';

import 'package:wemeet/utils/colors.dart';
import 'package:wemeet/utils/errors.dart';
import 'package:wemeet/utils/svg_content.dart';
import 'package:wemeet/utils/toast.dart';
import 'package:wemeet/utils/validators.dart';

class ResetPasswordPage extends StatefulWidget {

  final String email;
  const ResetPasswordPage({Key key, @required this.email}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailC = TextEditingController();
  TextEditingController passwordC = TextEditingController();
  TextEditingController confirmPasswordC = TextEditingController();
  TextEditingController tokenC = TextEditingController();

  FocusNode passwordNode = FocusNode();
  FocusNode confirmPasswordNode = FocusNode();
  FocusNode tokenNode = FocusNode();

  @override
  void initState() { 
    super.initState();
    
    emailC.text = widget.email;
  }

  @override
  void dispose() { 
    emailC.dispose();
    passwordC.dispose();
    confirmPasswordC.dispose();
    passwordNode.dispose();
    confirmPasswordNode.dispose();
    tokenNode.dispose();
    super.dispose();
  }

  void resetPassword() async {

    WeMeetLoader.showLoadingModal(context);

    Map data = {
      "email": emailC.text,
      "token": tokenC.text,
      "confirmPassword": confirmPasswordC.text,
      "password": passwordC.text
    };

    try {
      
      // check if valid token
      var tV = await AuthService.getVerifyToken(emailC.text, tokenC.text);
      print(tV);

      bool valid = tV["data"] as bool;

      if(!valid) {
        throw "Reset token is not valid. Please check your email and try again.";
      }

      // check reset response
      var res = await AuthService.postResetPassword(data);
      print(res);

      WeMeetToast.toast("Password reset successfully. Please proceed to login.");

      formKey.currentState.reset();

      await Future.delayed(Duration(seconds: 1));

      Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
      
    } catch (e) {
      WeMeetToast.toast(kTranslateError(e), true);
    } finally {
      if(Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  dynamic verifyToken() async {
    return await AuthService.getVerifyToken(emailC.text, tokenC.text);
  }

  void submit() {
    FocusScope.of(context).requestFocus(FocusNode());
    final FormState form = formKey.currentState;
    if(form.validate()) {
      form .save();
      resetPassword();
    }
  }

  Widget buildForm() {
    return Form(
      key: formKey,
      child: ListView(
        children: [
          SizedBox(height: 20.0),
          Center(
            child: SvgPicture.string(WemeetSvgContent.logoYB),
          ),
          SizedBox(height: 40.0),
          Text(
            "Reset your password.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.0
            ),
          ),
          SizedBox(height: 40.0),
          WeMeetTextField(
            controller: emailC,
            helperText: "Email Address",
            hintText: "Enter your email address",
            keyboardType: TextInputType.emailAddress,
            validator: EmailValidator.validate,
            enabled: false,
          ),
          SizedBox(height: 20.0),
          WeMeetTextField(
            controller: tokenC,
            focusNode: tokenNode,
            helperText: "Reset Token",
            hintText: "Reset Token",
            keyboardType: TextInputType.number,
            validator: NotEmptyValidator.validate,
            inputAction: TextInputAction.next,
            onFieldSubmitted: (val) {
              FocusScope.of(context).requestFocus(passwordNode);
            },
          ),
          SizedBox(height: 20.0),
          WeMeetTextField(
            controller: passwordC,
            focusNode: passwordNode,
            helperText: "New Password",
            hintText: "Enter your new password",
            validator: PasswordValidator.validate,
            isPassword: true,
            showPasswordToggle: true,
            inputAction: TextInputAction.next,
            onFieldSubmitted: (val) {
              FocusScope.of(context).requestFocus(confirmPasswordNode);
            },
          ),
          SizedBox(height: 20.0),
          WeMeetTextField(
            controller: confirmPasswordC,
            focusNode: confirmPasswordNode,
            helperText: "Confirm Password",
            hintText: "Confirm your new password",
            validator: (val) => ConfirmPasswordValidator.validate(val, passwordC.text),
            isPassword: true,
            showPasswordToggle: true,
            inputAction: TextInputAction.go,
            onFieldSubmitted: (val) {
              submit();
            },
          ),
          SizedBox(height: 30.0),
          WWideButton(
            title: "Reset Password",
            onTap: submit,
          )
        ],
        padding: EdgeInsets.symmetric(horizontal: 30.0),
        physics: ClampingScrollPhysics(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.color3,
        // title: Text("Reset Password"),
      ),
      body: Container(
        color: AppColors.color3,
        child: buildForm(),
      ),
    );
  }
}