import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wemeet/components/loader.dart';

import 'package:wemeet/components/text_field.dart';
import 'package:wemeet/components/wide_button.dart';
import 'package:wemeet/pages/reset_password.dart';
import 'package:wemeet/services/auth.dart';

import 'package:wemeet/utils/colors.dart';
import 'package:wemeet/utils/errors.dart';
import 'package:wemeet/utils/svg_content.dart';
import 'package:wemeet/utils/toast.dart';
import 'package:wemeet/utils/validators.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailC = TextEditingController();

  @override
  void dispose() { 
    emailC.dispose();
    super.dispose();
  }

  void sendCode() async {

    WeMeetLoader.showLoadingModal(context);

    try {

      await AuthService.getForgotPassword(emailC.text);

      Navigator.pop(context);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ResetPasswordPage(email: emailC.text,)
        )
      );
    } catch (e) {
      WeMeetToast.toast(kTranslateError(e));
      Navigator.pop(context);
    } 
  }

  void submit() {
    FocusScope.of(context).requestFocus(FocusNode());
    final FormState form = formKey.currentState;
    if(form.validate()) {
      form .save();
      sendCode();
    }
  }

  Widget buildForm() {
    return Form(
      key: formKey,
      child: ListView(
        children: [
          SizedBox(height: kToolbarHeight + 10.0),
          Center(
            child: SvgPicture.string(WemeetSvgContent.logoYB),
          ),
          SizedBox(height: 40.0),
          Text(
            "Recover your password.",
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
          ),
          SizedBox(height: 30.0),
          WWideButton(
            title: "Send Reset Code",
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
        title: Text("Forgot Password"),
      ),
      body: Container(
        color: AppColors.color3,
        child: buildForm()
      )
    );
  }
}