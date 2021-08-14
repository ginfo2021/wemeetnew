import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:ionicons/ionicons.dart';
import 'package:wemeet/components/dismissable_keyboard.dart';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/user.dart';

import 'package:wemeet/components/text_field.dart';
import 'package:wemeet/components/loader.dart';
import 'package:wemeet/components/wide_button.dart';
import 'package:wemeet/services/auth.dart';
import 'package:wemeet/services/user.dart';
import 'package:wemeet/utils/errors.dart';

import 'package:wemeet/utils/colors.dart';
import 'package:wemeet/utils/toast.dart';
import 'package:wemeet/utils/validators.dart';

class ActivatePage extends StatefulWidget {

  final AppModel model;
  const ActivatePage({Key key, this.model}) : super(key: key);

  @override
  _ActivatePageState createState() => _ActivatePageState();
}

class _ActivatePageState extends State<ActivatePage> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailC = TextEditingController();
  TextEditingController codeC = TextEditingController();

  FocusNode emailNode = FocusNode();
  FocusNode codeNode = FocusNode();

  AppModel model;

  @override
  void initState() { 
    super.initState();
    
    model = widget.model;
    emailC.text = model.user.email;
  }

  @override
  void dispose() { 
    emailC.dispose();
    codeC.dispose();
    emailNode.dispose();
    codeNode.dispose();
    super.dispose();
  }

  void activateAccount() async {
    WeMeetLoader.showLoadingModal(context);
    try {
      await AuthService.postVerifyEmail(codeC.text);
      WeMeetToast.toast("Account activated successfully");
      await fetchUser();
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
    final FormState form = formKey.currentState;
    if(form.validate()) {
      form.save();
      activateAccount();
    }
  }

  void resendCode() async {
    WeMeetLoader.showLoadingModal(context);
    try {
      await AuthService.postResendEmailToken();
      WeMeetToast.toast("Token sent successfully. Please check your email");
    } catch (e) {
      WeMeetToast.toast(kTranslateError(e), true);
    } finally {
      if(Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  void fetchUser() async {
    UserService.getProfile().then((res){
      Map data = res["data"] as Map;
      model.setUserMap(data);

      UserModel user = UserModel.fromMap(data);

      if(user.gender == null || user.gender.isEmpty) {
        Navigator.of(context).pushNamedAndRemoveUntil("/preference", (route) => false);
        return;
      }

      if(data["profileImage"] == null) {
        Navigator.of(context).pushNamedAndRemoveUntil("/complete-profile", (route) => false);
        return;
      }
    });
  }

  Widget buildForm() {
    return Form(
      key: formKey,
      child: ListView(
        children: [
          SizedBox(height: 50.0),
          WeMeetTextField(
            controller: emailC,
            hintText: "Email Address",
            enabled: false,
            keyboardType: TextInputType.emailAddress,
            validator: EmailValidator.validate,
            prefixIcon: Icon(Ionicons.mail_outline, color: Colors.grey),
          ),
          SizedBox(height: 30.0),
          WeMeetTextField(
            controller: codeC,
            hintText: "Activation Code",
            keyboardType: TextInputType.number,
            validator: (val) => NotEmptyValidator.validate(val, null, "Enter reset code"),
            prefixIcon: Icon(Ionicons.lock_closed_outline, color: Colors.grey),
            onFieldSubmitted: (val) {

            },
          ),
          SizedBox(height: 10.0,),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: resendCode,
              child: Text(
                "Resend Activation Code",
                style: TextStyle(
                  color: AppColors.orangeColor
                ),
              ),
            ),
          ),
          SizedBox(height: 40.0),
          WWideButton(
            title: "Activate Account",
            onTap: submit,
          ),
          SizedBox(height: 30.0),
          Text.rich(
            TextSpan(
              text: "Login with another account.",
              recognizer: TapGestureRecognizer()..onTap = (){
                Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
                model.logOut();
              }
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.0,
              decoration: TextDecoration.underline,
              // color: AppColors.color4
            ),
          ),
        ],
        padding: EdgeInsets.symmetric(horizontal: 30.0),
        physics: ClampingScrollPhysics(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color3,
      appBar: AppBar(
        backgroundColor: AppColors.color3,
        title: Text("Activate Account"),
      ),
      body: Container(
        child: WKeyboardDismissable(child: buildForm())
      ),
    );
  }
}