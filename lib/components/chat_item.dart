import 'package:flutter/material.dart';

import 'package:wemeet/models/chat.dart';

import 'package:wemeet/components/chat_player.dart';

class ChatItem extends StatelessWidget {

  final ChatModel chat;
  final int uid;
  const ChatItem({Key key, this.chat, this.uid}) : super(key: key);

  Widget buildText(bool me) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      margin: EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: me
            ? Color(0xffdedede)
            : Color(0xfff4f4f4),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(me ? 10 : 0),
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(me ? 0 : 10)
        )
      ),
      child: Wrap(
        children: [
          Text(
            chat.content,
            style: TextStyle(
              fontSize: 15.0
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContent(bool me) {
    Widget b = Container();

    switch (chat.type) {
      case "TEXT":
        b = buildText(me);
        break;
      case "MEDIA":
        b = ChatPlayer(url: chat.content,);
        break;
      default: b = Container();
    }

    return b;
  }

  @override
  Widget build(BuildContext context) {

    final bool me = chat.senderId == uid;

    return Container(
      child: Stack(
        alignment: me ? Alignment.centerRight : Alignment.centerLeft,
        children: [
          Container(
            constraints: BoxConstraints(minWidth: 150.0, maxWidth: 350.0),
            child: Column(
              crossAxisAlignment: me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                buildContent(me)
              ],
            ),
          )
        ],
      ),
    );
  }
}