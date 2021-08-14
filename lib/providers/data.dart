import 'dart:async';
import 'package:location/location.dart' show LocationData;

import 'package:wemeet/models/user.dart';

class DataProvider {
  DataProvider._internal();

  static final DataProvider _dataProvider = DataProvider._internal();

  factory DataProvider(){
    return _dataProvider;
  }

  String _deviceId;
  String get deviceId => _deviceId;

  void setDeviceId(String val){
    print("Setting Device Id: $val");
    _deviceId = val;
  }

  String _token;
  String get token => _token;

  void setToken(String t){
    print(t);
    _token = t;
  }

  String _messageToken;
  String get messageToken => _messageToken;

  void setMessageToken(String t){
    print(t);
    _messageToken = t;
  }

  String _pushToken;
  String get pushToken => _pushToken;

  void setPushToken(String t){
    print(t);
    _pushToken = t;
  }

  LocationData _location;
  LocationData get location => _location;

  void setLocation(LocationData t){
    print(t);
    _location = t;
  }

  // Location filter
  String _locationFilter = "true";
  String get locationFilter => _locationFilter;
  void setlocationFilter(String val) {
    _locationFilter = val ?? "true";
  }

  // User
  UserModel _user;
  UserModel get user => _user;

  void setUser(UserModel val) {
    _user = val;
  }

  // new chat stream controller
  StreamController<bool> _reloadController =
      StreamController<bool>.broadcast();
  Stream<bool> get onReload =>
      _reloadController.stream;
  
  void reloadData() {
    _reloadController.add(true);
  }

  // new chat stream controller
  StreamController<String> _reloadPageController =
      StreamController<String>.broadcast();
  Stream<String> get onReloadPage =>
      _reloadPageController.stream;
  
  void reloadPage(String page) {
    _reloadPageController.add(page);
  }

  StreamController<int> _navPageController =
      StreamController<int>.broadcast();
  Stream<int> get onNavPageChanged => _navPageController.stream;

  void setNavPage(int val){
    _navPageController.add(val);
  }
}