import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';

import 'package:wemeet/app.dart';

import 'package:wemeet/models/app.dart';

// Declare Shared Preference
SharedPreferences prefs;

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize firebase
  await Firebase.initializeApp();

  // initialize shared preference
  prefs = await SharedPreferences.getInstance();

  // initialize AppModel
  AppModel model = AppModel();

  var data = prefs.getString("app");
  if(data != null){
    var t = jsonDecode(data);
    model.init(t, prefs);
  } else {
    await prefs.setString("app", "{}");
    model.init({}, prefs);
  }

  // start socket service. Uncomment this on live
  // SocketService().init();
  // BackgroundSocketService().start(WeMeetConfig.socketUrl);

  runApp(WeMeetApp(model: model));
}