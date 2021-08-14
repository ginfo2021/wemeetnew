import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:wemeet/models/chat.dart';
import 'package:wemeet/pages/chat.dart';

class MessageItem extends StatelessWidget {

  final int uid;
  final ChatModel message;
  const MessageItem({Key key, this.message, this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final String id = message.senderId == uid ? "${message.receiverId}" : "${message.senderId}";

    return Container(
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ChatPage(uid: id ?? message.chatId)
          ));
        },
        leading: Container(
          width: 60.0,
          height: 60.0,
          child: Stack(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 25.0,
                  backgroundImage:CachedNetworkImageProvider(message.avatar),
                ),
              ),
              if(message.withBubble) Positioned(
                right: 10.0,
                bottom: 0.0,
                child: Container(
                  width: 10.0,
                  height: 20.0,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle
                  ),
                ),
              )
            ],
          ),
        ),
        title: Text("${message.name}"),
        subtitle: Text(
          (message.type == "MEDIA")
              ? "audio..."
              : message.content,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontStyle: (message.type == "MEDIA")
                ? FontStyle.italic
                : FontStyle.normal),
        ),
        trailing: Text(
          "${message.ago}",
          style: TextStyle(fontSize: 11.0),
        )
            
      ),
    );
  }
}