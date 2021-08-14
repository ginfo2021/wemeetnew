import 'package:flutter/material.dart';

import 'package:wemeet/components/loader.dart';

import 'package:wemeet/models/app.dart';

import 'package:wemeet/models/user.dart';
import 'package:wemeet/providers/data.dart';
import 'package:wemeet/services/auth.dart';

import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show jsonDecode;

class SocialLoginPage extends StatefulWidget {
  final AppModel model;

  const SocialLoginPage({Key key, this.model}) : super(key: key);

  @override
  _SignInPage createState() => _SignInPage();
}

//class _LoginPageState extends State<LoginPage> {

class _SignInPage extends State<SocialLoginPage> {
  /*----SOCIAL FB LOGIN - START --------*/

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

  final FacebookLogin facebookSignIn = new FacebookLogin();

  String _message = 'Log in/out by pressing the buttons below.';

  Future<Null> _login(BuildContext context) async {
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

          doLogin();
        } catch (e) {
          print(e);
          //WeMeetToast.toast(kTranslateError(e), true);
        } finally {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }

        /*_showMessage('''
          Logged in!
          
          Token: ${accessToken.token}
          User id: ${accessToken.userId}
          Expires: ${accessToken.expires}
          Permissions: ${accessToken.permissions}
          Declined permissions: ${accessToken.declinedPermissions}
          ''');*/
        break;
      case FacebookLoginStatus.cancelledByUser:
        _showMessage('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        _showMessage('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }
  }

  void doLogin() async {
    WeMeetLoader.showLoadingModal(context);
    DataProvider _dp = DataProvider();
    Map data = {
      "deviceId": _dp.pushToken,
      "latitude": _dp.location.latitude,
      "longitude": _dp.location.longitude,
      "email": "ansarimuzammil606@gmail.com",
      "password": "123456"
    };

    await Future.delayed(Duration(seconds: 1));

    try {
      var res = await AuthService.postLogin(data);

      Map resData = res["data"] as Map;
      print(resData);
      UserModel user = UserModel.fromMap(resData["user"]);

      Map userData = resData["user"] as Map;

      // set user
      model.setUserMap(userData);
      // set user token
      model.setToken(resData["tokenInfo"]["accessToken"]);

      // check verification
      verifyUser(user);
    } catch (e) {
      print(e);
      //WeMeetToast.toast(kTranslateError(e));
    } finally {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
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

  Future<Null> _logOut() async {
    await facebookSignIn.logOut();
    _showMessage('Logged out.');
  }

  void _showMessage(String message) {
    /*setState(() {
        _message = message;
      });*/
  }

  /*----SOCIAL FB LOGIN - END --------*/

  /// Show a simple "___ Button Pressed" indicator
  void _showButtonPressDialog(BuildContext context, String provider) {
    _login(context);
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('$provider Button Pressed!'),
      backgroundColor: Colors.black26,
      duration: Duration(milliseconds: 1000),
    ));
  }
  //static final FacebookLogin facebookSignIn = new FacebookLogin();

  /// Normally the signin buttons should be contained in the SignInPage
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          /* SignInButtonBuilder(
            text: 'Get going with Email',
            icon: Icons.email,
            onPressed: () {
              _showButtonPressDialog(context, 'Email');
            },
            backgroundColor: Colors.blueGrey[700],
            width: 220.0,
          ),3
          Divider(),
          SignInButton(
            Buttons.Google,
            onPressed: () {
              _showButtonPressDialog(context, 'Google');
            },
          ),
          Divider(),
          SignInButton(
            Buttons.GoogleDark,
            onPressed: () {
              _login;
            },
          ),
          Divider(),*/
          SignInButton(
            Buttons.FacebookNew,
            onPressed: () {
              _showButtonPressDialog(context, 'FacebookNew');
            },
          ),
          /*Divider(),
          SignInButton(
            Buttons.Apple,
            onPressed: () {
              //_showButtonPressDialog(context, 'Apple');
            },
          ),
           Divider(),
          SignInButton(
            Buttons.GitHub,
            text: "Sign up with GitHub",
            onPressed: () {
              _showButtonPressDialog(context, 'Github');
            },
          ),
          Divider(),
          SignInButton(
            Buttons.Microsoft,
            text: "Sign up with Microsoft ",
            onPressed: () {
              _showButtonPressDialog(context, 'Microsoft ');
            },
          ),
          Divider(),
          SignInButton(
            Buttons.Twitter,
            text: "Use Twitter",
            onPressed: () {
              _showButtonPressDialog(context, 'Twitter');
            },
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SignInButton(
                Buttons.LinkedIn,
                mini: true,
                onPressed: () {
                  _showButtonPressDialog(context, 'LinkedIn (mini)');
                },
              ),
              SignInButton(
                Buttons.Tumblr,
                mini: true,
                onPressed: () {
                  _showButtonPressDialog(context, 'Tumblr (mini)');
                },
              ),
              SignInButton(
                Buttons.Facebook,
                mini: true,
                onPressed: () {
                  _showButtonPressDialog(context, 'Facebook (mini)');
                },
              ),
              SignInButtonBuilder(
                icon: Icons.email,
                text: "Ignored for mini button",
                mini: true,
                onPressed: () {
                  _showButtonPressDialog(context, 'Email (mini)');
                },
                backgroundColor: Colors.cyan,
              ),
            ],
          ),*/
        ],
      ),
    );
  }
}
