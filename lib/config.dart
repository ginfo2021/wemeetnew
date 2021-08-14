import 'package:flutter/foundation.dart';

class WeMeetConfig {
  // Messaging base url
  static const String messageBase = "messaging-service/v1/";
  static const bool bTrue = false;

  static String get socketUrl {
    //if(kReleaseMode) {
    if (bTrue) {
      return "http://prod.wemeet.africa/api/messaging-service/socket";
    }
    return "http://dev.wemeet.africa/api/messaging-service/socket";
  }

  // base url
  static String get baseUrl {
    //if(kReleaseMode) {
    if (bTrue) {
      return "https://prod.wemeet.africa/api/";
    }
    return "https://dev.wemeet.africa/api/";
  }

  // Paystack key
  static String get payStackPublickKey {
    if (bTrue) {
      return "pk_live_b747bf32e4fb87b0824a49f3dc4abb831ac64764";
    }
    return "pk_test_1ee70468f4f53355ca5b88f3f4d4ac0dd9504749";
  }

  static String mapsKey = "AIzaSyDr-EyWx9exuZVkbYCv_50rzRJUoVlYRe4";
}
