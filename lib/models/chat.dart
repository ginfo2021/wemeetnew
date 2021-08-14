import 'package:date_format/date_format.dart';

class ChatModel {
  final int id;
  final String content;
  final DateTime sentAt;
  final String type;
  final int receiverId;
  final int senderId;
  final String chatId;
  final int status;

  bool withBubble = false;
  String avatar;
  String name;

  ChatModel({
    this.id,
    this.content,
    this.type,
    this.receiverId,
    this.senderId,
    this.chatId,
    this.status,
    this.sentAt
  });

  factory ChatModel.fromMap(Map data) {
    return ChatModel(
      id: data["id"],
      content: data["content"],
      sentAt: DateTime.tryParse(data["sent_at"]).toLocal(),
      type: data["type"] ?? "",
      receiverId: data["receiver_id"],
      senderId: data["sender_id"],
      status: data["status"] ?? 0,
      chatId: data["chat_id"] ?? ""
    );
  }

  String get fDate {

    DateTime now = DateTime.now();

    // check if today
    if(now.year == sentAt.year && now.month == sentAt.month && now.day == sentAt.day) {
      return formatDate(sentAt, [hh, ':', nn, ' ', am]);
    } 

    return formatDate(sentAt, [dd, ' ', M, ', ', yyyy]);

  }

  String get ago {
    int mill = DateTime.now().toLocal().millisecondsSinceEpoch - sentAt.millisecondsSinceEpoch;
    if(mill < 0) {
      return "just now";
    }

    Duration dur = Duration(milliseconds: mill);

    int hrs = dur.inHours;
    // check if minutes
    if(hrs < 1) {
      return "${dur.inMinutes} mins ago";
    }

    // if more than just an hour
    if(hrs > 0 && hrs < 20) {
      return formatDate(sentAt, [hh, ':', nn, ' ', am]);
    }

    return formatDate(sentAt, [dd, ' ', M, ', ', yyyy]);
  }

  String get chatDate {
    return formatDate(sentAt, [hh, ':', nn, ' ', am]);
  }

  int get timestamp {
    return sentAt.millisecondsSinceEpoch;
  }

  String get tag {

    DateTime now = DateTime.now();

    // check if today
    if(now.year == sentAt.year && now.month == sentAt.month && now.day == sentAt.day) {
      return "Today";
    }

    // check if yesterday
    if(now.year == sentAt.year && now.month == sentAt.month && now.day == (sentAt.day + 1)) {
      return "Yesterday";
    }

    return formatDate(sentAt, [dd, ' ', M, ', ', yyyy]);
  }
}