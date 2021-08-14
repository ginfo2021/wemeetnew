import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:bot_toast/bot_toast.dart';
import 'dart:math' as math;

import 'package:wemeet/models/app.dart';

import 'package:wemeet/pages/start.dart';
import 'package:wemeet/pages/home.dart';
import 'package:wemeet/pages/404.dart';
import 'package:wemeet/pages/on_boarding.dart';
import 'package:wemeet/pages/register.dart';
import 'package:wemeet/pages/login.dart';
import 'package:wemeet/pages/forgot_password.dart';
import 'package:wemeet/pages/settings.dart';
import 'package:wemeet/pages/activate.dart';
import 'package:wemeet/pages/messages.dart';
import 'pages/preference.dart';
import 'pages/complete_profile.dart';
import 'pages/matches.dart';
import 'pages/change_password.dart';
import 'pages/blocked_users.dart';
import 'pages/change_location.dart';

import 'package:wemeet/utils/colors.dart';

class WeMeetApp extends StatelessWidget {
  final AppModel model;

  const WeMeetApp({Key key, this.model}) : super(key: key);

  Map<String, WidgetBuilder> _buildRoutes() {
    final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
      "/": (context) => StartPage(model: model),
      "/start": (context) => StartPage(model: model),
      //"/on-boarding": (context) => OnBoardingPage(),
      "/on-boarding": (context) => VideoApp(),
      "/home": (context) => HomePage(
            model: model,
          ),
      "/login": (context) => LoginPage(
            model: model,
          ),
      "/register": (context) => RegisterPage(
            model: model,
          ),
      "/forgot-password": (context) => ForgotPasswordPage(),
      "/change-password": (context) => ChangePasswordPage(),
      "/settings": (context) => SettingsPage(model: model),
      "/activate": (context) => ActivatePage(model: model),
      "/preference": (context) => UserPreferencePage(model: model),
      "/complete-profile": (context) => CompleteProfilePage(model: model),
      "/messages": (context) => MessagesPage(),
      "/matches": (context) => MatchesPage(model: model),
      "/blocked-users": (context) => BlockedUsersPage(model: model),
      ("/change-location"): (context) => ChangeLocationPage(model: model)
    };

    return routes;
  }

  @override
  Widget build(BuildContext context) {
    // BotToast builder
    final botToastBuilder = BotToastInit();

    return ScopedModel<AppModel>(
      model: model,
      child: MaterialApp(
        title: "WeMeet",
        // builder: BotToastInit(),
        builder: (BuildContext context, Widget child) {
          final MediaQueryData data = MediaQuery.of(context);
          return MediaQuery(
            data: data.copyWith(
              textScaleFactor: math.min(data.textScaleFactor, 1.0),
              // platformBrightness: data.platformBrightness
            ),
            child: botToastBuilder(context, child),
          );
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: Colors.white,
            accentColor: AppColors.color1,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            scaffoldBackgroundColor: Colors.white,
            fontFamily: "Nunito",
            buttonColor: AppColors.color1,
            buttonTheme: ButtonThemeData(
                buttonColor: AppColors.color1,
                textTheme: ButtonTextTheme.primary,
                highlightColor: Colors.transparent),
            appBarTheme: AppBarTheme(
                color: Colors.white,
                brightness: Brightness.light,
                elevation: 0.0,
                actionsIconTheme: IconThemeData(
                  color: AppColors.color1,
                ),
                textTheme: TextTheme(
                    headline6: TextStyle(
                        color: AppColors.deepPurpleColor,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                        fontFamily: "Nunito")))),
        routes: _buildRoutes(),
        navigatorObservers: [BotToastNavigatorObserver()],
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (_) => NotFoundPage());
        },
      ),
    );
  }
}
