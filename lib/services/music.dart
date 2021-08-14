import 'package:wemeet/utils/api.dart';

class MusicService {

  static Future getList([Map data = const {"pageNum": 0, "pageSize": 10}]) => api.get("backend-service/v1/file/music", query: data);
  
  static Future postRequest(Map data) => api.post("backend-service/v1/user/song-request", data: data);

}
