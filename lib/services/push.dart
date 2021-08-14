import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';

import 'package:wemeet/models/app.dart';

import 'package:wemeet/services/user.dart';


class PushService {

  PushService._internal();

  static final PushService _pushService = PushService._internal();

  factory PushService() {
    return _pushService;
  }

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void configure(AppModel model) async {

    await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        showNotification(message.notification);
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    /*firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('onMessage: $message');
        Platform.isAndroid
            ? showNotification(message['notification'])
            : showNotification(message['aps']['alert']);
        return;
      },
      onBackgroundMessage:
          Platform.isAndroid ? myBackgroundMessageHandler : null,
      onResume: (Map<String, dynamic> message) {
        print('onResume: $message');
        return;
      },
      onLaunch: (Map<String, dynamic> message) {
        print('onLaunch: $message');
        return;
      });
    */

    firebaseMessaging.getToken().then((token) {
      print("Push Token: $token");
      model.setPushToken(token);
    }).catchError((err) {
      print('err: $err');
    });

    firebaseMessaging.onTokenRefresh.listen((token) {
      updateToken(model, token);
    });
  }

  void showNotification(message) async {

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'com.africa.wemeet',
      'WeMeet',
      'Swipe, Meet',
      playSound: true,
      enableVibration: false,
      importance: Importance.max,
      priority: Priority.high,
    );

    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, 
      "${message['title'] ?? ""}",
      "${message['body'] ?? ""}", 
      platformChannelSpecifics,
      payload: jsonEncode(message));
  }

  void updateToken(AppModel model, String token) {

    print("New Push token: $token");

    model.setPushToken(token);

    if(model.user != null && model.user.id != null) {
      UserService.postUpdateDevice({
        "old": model.pushToken,
        "new": token
      }).then((val) {
        print("Push Token updated");
      });
    }
  }


}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    // Handle data message
    // final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    // final dynamic notification = message['notification'];
  }
}