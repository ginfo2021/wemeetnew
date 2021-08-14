import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:wemeet/components/loader.dart';
import 'package:wemeet/components/wide_button.dart';

import 'package:wemeet/models/app.dart';

import 'package:wemeet/components/text_field.dart';
import 'package:wemeet/models/user.dart';
import 'package:wemeet/providers/data.dart';
import 'package:wemeet/services/auth.dart';

import 'package:wemeet/utils/colors.dart';
import 'package:wemeet/utils/errors.dart';
import 'package:wemeet/utils/svg_content.dart';
import 'package:wemeet/utils/toast.dart';
import 'package:wemeet/utils/validators.dart';
import 'package:wemeet/utils/url.dart';
import 'package:wemeet/models/social_signin.dart';
import 'package:wemeet/models/apple_signin.dart';

import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show jsonDecode;

class LoginPage extends StatefulWidget {
  final AppModel model;

  const LoginPage({Key key, this.model}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController _emailC = TextEditingController();
  TextEditingController _passwordC = TextEditingController();

  FocusNode _emailNode = FocusNode();
  FocusNode _passwordNode = FocusNode();

  DataProvider _dp = DataProvider();

  AppModel model;

  @override
  void initState() {
    super.initState();

    model = widget.model;
  }

  @override
  void dispose() {
    _emailC.dispose();
    _passwordC.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();

    super.dispose();
  }

  void doLogin(String sType, String semail) async {
    WeMeetLoader.showLoadingModal(context);
    Map data = {};

    if (sType == "FB") {
      data = {
        "deviceId": _dp.pushToken,
        "latitude": _dp.location.latitude,
        "longitude": _dp.location.longitude,
        "email": "ansarimuzammil606@gmail.com",
        "password": "123456"
      };
    } else {
      data = {
        "deviceId": _dp.pushToken,
        "latitude": _dp.location.latitude,
        "longitude": _dp.location.longitude,
        "email": _emailC.text,
        "password": _passwordC.text
      };
    }

    await Future.delayed(Duration(seconds: 1));

    try {
      var res = await AuthService.postLogin(data);

      Map resData = res["data"] as Map;
      print(resData);
      UserModel user = UserModel.fromMap(resData["user"]);

      // set user
      model.setUserMap(resData["user"]);
      // set user token
      model.setToken(resData["tokenInfo"]["accessToken"]);

      // check verification
      verifyUser(user);
    } catch (e) {
      print(e);
      WeMeetToast.toast(kTranslateError(e));
    } finally {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

/*----Siocial Sigin ----*/
  Future<Null> _fbsignin(BuildContext context) async {
    final FacebookLogin facebookSignIn = new FacebookLogin();

    String _message = 'Log in/out by pressing the buttons below.';

//   login() async {
    final FacebookLoginResult result = await facebookSignIn.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        final token = result.accessToken.token;
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,gender,picture&access_token=${token}');
        final profile = jsonDecode(graphResponse.body);
        print(profile);

        //WeMeetLoader.showLoadingModal(context);

        //List<String> name = profile.text.split(" ");

        Map data = {
          "dateOfBirth": DateTime.parse('2001-04-01').toIso8601String(),
          "deviceId": _dp.deviceId,
          "email": profile['email'],
          "firstName": profile['first_name'],
          "lastName": profile['last_name'],
          "latitude": _dp.location?.latitude ?? 0,
          "longitude": _dp.location?.longitude ?? 0,
          "password": '123456',
          // "phone": _phoneC.text,
          "userName": profile['email'],
          "active": true
        };

        try {
          var resUser = await AuthService.postSocialSignup(data);
          /* if (res == "EXISTS") {
            //login
          }*/

          Map resUserData = resUser["data"] as Map;

          // print(resData);
          Map userData = resUserData["user"] as Map;

          doLogin("FB", profile['email']);
        } catch (e) {
          print(e);
          //WeMeetToast.toast(kTranslateError(e), true);
        } finally {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
    }
  }

/*------END-----*/
  void submit() {
    FocusScope.of(context).unfocus();
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      doLogin("NORMAL", "");
    }
  }

  void verifyUser(UserModel user) {
    if (!user.active) {
      Navigator.pushNamedAndRemoveUntil(context, "/activate", (route) => false);
      return;
    }

    if (user.gender == null || user.gender.isEmpty) {
      Navigator.pushNamedAndRemoveUntil(
          context, "/preference", (route) => false);
      return;
    }

    if (user.profileImage == null) {
      Navigator.pushNamedAndRemoveUntil(
          context, "/complete-profile", (route) => false);
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
    //Navigator.pushNamedAndRemoveUntil(context, "/profile", (route) => false);
  }

  Widget buildForm() {
    return Form(
      key: formKey,
      child: ListView(
        children: [
          SizedBox(height: kToolbarHeight + 10.0),
          Center(
            child: SvgPicture.string(WemeetSvgContent.logoWY),
          ),
          SizedBox(height: 40.0),
          Text(
            "Welcome Back",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17.0, color: Colors.white),
          ),
          SizedBox(height: 40.0),
          WeMeetTextField(
            // helperText: "Email Address",
            controller: _emailC,
            focusNode: _emailNode,
            hintText: "Email Address",
            keyboardType: TextInputType.emailAddress,
            validator: EmailValidator.validate,
            borderColor: AppColors.color3,
            hintColor: Colors.white,
            textColor: Colors.white,
            errorColor: AppColors.orangeColor,
            inputAction: TextInputAction.next,
            onFieldSubmitted: (val) {
              FocusScope.of(context).requestFocus(_passwordNode);
            },
          ),
          SizedBox(height: 40.0),
          WeMeetTextField(
            // helperText: "Password",
            controller: _passwordC,
            focusNode: _passwordNode,
            hintText: "Password",
            isPassword: true,
            showPasswordToggle: true,
            validator: (val) => NotEmptyValidator.validateWithMessage(
                val, "Please enter you password"),
            borderColor: AppColors.color3,
            hintColor: Colors.white,
            textColor: Colors.white,
            errorColor: AppColors.orangeColor,
            inputAction: TextInputAction.go,
            onFieldSubmitted: (val) {
              submit();
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed("/forgot-password");
              },
              child: Text(
                "Forgot Password?",
                style: TextStyle(color: AppColors.orangeColor),
              ),
            ),
          ),
          SizedBox(height: 40.0),
          Text.rich(
            TextSpan(text: "Don't have an account? ", children: [
              TextSpan(
                  text: "Sign Up.",
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: AppColors.color4),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.of(context).pushReplacementNamed("/register");
                    }),
            ]),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.0, color: AppColors.color4),
          ),
          SizedBox(height: 40.0),
          WWideButton(
            title: "Sign In",
            color: AppColors.yellowColor,
            onTap: submit,
            textColor: AppColors.color1,
          ),
          SizedBox(height: 30.0),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SignInButton(
                  Buttons.FacebookNew,
                  onPressed: () {
                    _fbsignin(context);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 30.0),
          Center(
            child: AppleSigninPage(),
          ),
          SizedBox(height: 30.0),
          Text.rich(
            TextSpan(
                text: "By Using the WeMeet platform, you agree to our ",
                children: [
                  TextSpan(
                      text: "Terms of Use",
                      style: TextStyle(decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          openURL("https://wemeet.africa/terms-of-use.html");
                        }),
                  TextSpan(text: " & "),
                  TextSpan(
                      text: "Privacy Policy.",
                      style: TextStyle(decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          openURL("https://wemeet.africa/privacy-policy.html");
                        })
                ]),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.0, color: AppColors.color4),
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
      backgroundColor: AppColors.color1,
      body: SafeArea(
        child: Container(child: buildForm()),
      ),
    );
  }
}
