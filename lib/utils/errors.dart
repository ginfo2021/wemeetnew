import 'package:flutter/services.dart';
import 'dart:io';

String kTranslateError(dynamic e){
  if(e is PlatformException){
    switch (e.message) {
      case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
        return 'Connection error occured.';
        break;
      default:
        return 'Unknown error occured.';
    }
  } 

  if(e is FormatException) {
    return "Invalid response format";
  }
  
  if(e is SocketException){
    String mssg = e.toString();

    if(mssg.contains("Connection refused")){
      return "Connection refused by the server";
    }

    if(mssg.contains("failed host lookup")){
      return "Internet connection error.";
    }

    return "Error connecting to the server";
  }

  if(e is String){
    return e;
  }

  if(e is Map && e["message"] != null && e["message"] is String){
    String mssg = e["message"].toLowerCase();
    if(mssg.contains("expire") && mssg.contains("token")) {
      return "Your session has expired. Please sign in again.";
    }
    return e["message"];
  }

  return 'An unexpected error occured.';
}