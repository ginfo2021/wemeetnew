import 'package:wemeet/utils/api.dart';

import 'package:wemeet/providers/data.dart';

class MessageService {

  static Future getChats() => api.get("messaging-service/v1/chats", reqToken: DataProvider().messageToken);

  static Future postSendMessage(Map body) => api.post("messaging-service/v1/send", data: body, reqToken: DataProvider().messageToken);

  static Future getConversation(String peerId) => api.get("messaging-service/v1/$peerId", reqToken: DataProvider().messageToken);

  static Future postLogin() => api.post("messaging-service/v1/login", data:{"userId": DataProvider().user.id.toString()});
}