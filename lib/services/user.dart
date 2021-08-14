import 'package:wemeet/utils/api.dart';

// import 'package:wemeet/providers/data.dart';

class UserService {
  
  static Future getProfile() => api.get("backend-service/v1/user/profile");

  static Future postUpdateProfile(dynamic data) => api.post("backend-service/v1/user/profile", data: data);

  static Future postUpdateProfileImages(dynamic data) => api.post("backend-service/v1/user/profile/image", data: data);

  static Future postUpdateDevice(dynamic data) => api.post("backend-service/v1/auth/device", data: data);

  static Future postPhoto(String filePath, String imageType) => api.upload("backend-service/v1/file/upload", filePath, imageType);

  static Future postUpdateLocation(Map body) => api.post("backend-service/v1/user/location", data: body);

  static Future getBlockedUsers([Map data = const {"pageNum": 0, "pageSize": 10}]) =>
      api.get("backend-service/v1/user/blocks", query: data);
  
  static Future postBlockUser(String id) => api.post("backend-service/v1/user/block?userId=$id");

  static Future postUnblockUser(String id) => api.post("backend-service/v1/user/unblock?userId=$id");

  static Future postReportUser(Map body) => api.post("backend-service/v1/user/report", data: body);

}