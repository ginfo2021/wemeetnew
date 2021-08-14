import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:async';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/user.dart';
import 'package:wemeet/models/chat.dart';

import 'package:wemeet/services/message.dart';
import 'package:wemeet/services/socket_bg.dart';
import 'package:wemeet/services/audio.dart';
import 'package:wemeet/services/user.dart';

import 'package:wemeet/pages/songs.dart';

import 'package:wemeet/components/chat_item.dart';
import 'package:wemeet/components/flag_user.dart';
import 'package:wemeet/components/report_user_dialog.dart';
import 'package:wemeet/components/error.dart';
import 'package:wemeet/components/loader.dart';
import 'package:wemeet/utils/colors.dart';

import 'package:wemeet/utils/toast.dart';
import 'package:wemeet/utils/errors.dart';

class ChatPage extends StatefulWidget {

  final String uid;
  final String avatar;
  final String name;
  const ChatPage({Key key, this.uid, this.avatar, this.name}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  bool isLoading = false;
  bool isError = false;
  String errorText;
  List<ChatModel> chats = [];

  final TextEditingController inputC = TextEditingController();
  FocusNode inputNode = FocusNode();

  AutoScrollController _indexScrollController =
      AutoScrollController(axis: Axis.vertical);
  BackgroundSocketService socketService = BackgroundSocketService();
  
  StreamSubscription<ChatModel> onChatMessage;
  StreamSubscription chatsSub;

  String uid;
  AppModel model;
  UserModel user;

  @override
  void initState() { 
    super.initState();
    
    uid = widget.uid;

    getUid(true);
    fetchChats(true);

    onChatMessage = socketService?.onChatReceived?.listen(onChatReceive);
    waitJoinRoom();
  }

  @override
  void dispose() { 
    onChatMessage?.cancel();
    chatsSub?.cancel();
    inputNode?.dispose();
    inputC?.dispose();
    WeMeetAudioService().stop();
    super.dispose();
  }

  String get chatId {
    if(chats.isNotEmpty) return chats.first.chatId;
    if(widget.uid.contains("_")) return widget.uid;
    if(user == null) return "";

    List ids = ["${user.id}", "${widget.uid}"];
    ids.sort((a, b) => a.compareTo(b));
    print(ids);
    return ids.join("_");
  }

  void fetchChats([bool delay = false]) async {
    // if(delay) {
    //   await Future.delayed(Duration(milliseconds: 200));
    // }

    await getUid(true); 

    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {
      var res = await MessageService.getConversation(uid);
      List data = res["data"]["messages"];
      setState(() {
        chats = data.reversed.map<ChatModel>((e) => ChatModel.fromMap(e)).toList();
      });
    } catch (e) {
      print(e);
      String err = kTranslateError(e);
      if(!err.toLowerCase().contains("token")) {
        setState(() {
          errorText = "Could not fetch chats";
        });
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void getUid([bool delay = false]) async {
    if(!uid.contains("_")) return;
    if(delay) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    List uL = uid.split("_");
    print("User Ids: $uL");
    setState(() {
      uid = (uL.first == "${user.id}") ? uL.last : uL.first;
    });
  }

  void waitJoinRoom() async {
    Timer(Duration(seconds: 2), () {
      socketService.join(chatId);
      socketService.setRoom(chatId);
    });
  }

  void onChatReceive(ChatModel chat) {
    final int i = chats.indexWhere((e) => chat.id == e.id);
    if(chat.id != null && i < 0) {
      setState(() {
         chats.insert(0, chat);       
      });

      _scrollToBottom(checkPosition: true);
    }
  }

  void sendMessage({String content, String type = "TEXT"}) async {
    if(inputC.text.isEmpty && type == "TEXT") {
      return;
    }

    if((content == null || content.isEmpty) && type == "MEDIA") {
      return;
    }

    if(chatId == null || chatId.isEmpty) {
      return;
    }

    content = content ?? inputC.text;
    
    Map data = {
      "content": content.trim(),
      "receiverId": uid,
      "type": type
    };

    try {
      var res = await MessageService.postSendMessage(data);
      Map mssg = res["data"]["message"] as Map;
      onChatReceive(ChatModel.fromMap(mssg));
    } catch (e) {
      print("Error: $e");
      WeMeetToast.toast(kTranslateError(e), true);
    } finally {
      inputC.clear();
    }
  }

  void _scrollToBottom({bool delay = false, bool checkPosition = false}) async {

    if (delay) {
      await Future.delayed(Duration(seconds: 1));
    }

    if (!_indexScrollController.hasClients) {
      print("No clients");
      return;
    }

    if (checkPosition) {
      double pos = _indexScrollController.position.pixels;
      double max = _indexScrollController.position.maxScrollExtent;

      if ((max - pos) > 50.0) {
        return;
      }
    }

    if (chats != null) {
      _indexScrollController.scrollToIndex(0,
          preferPosition: AutoScrollPosition.end,
          duration: Duration(seconds: 1));
    }
  }

  void blockUser() async {
    WeMeetLoader.showLoadingModal(context);

    try {
      var res = await UserService.postBlockUser(uid);
      WeMeetToast.toast(res["message"] ?? "User blocked", true);
      Navigator.of(context).popUntil(ModalRoute.withName("/home"));
    } catch (e) {
      WeMeetToast.toast(kTranslateError(e), true);
    } finally {
      if(Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  void reportUser(String reason) async {
    
    WeMeetLoader.showLoadingModal(context);

    try {
      var res = await UserService.postReportUser({"type": reason, "userId": uid});
      WeMeetToast.toast(res["message"] ?? "User Reported", true);
      Navigator.of(context).popUntil(ModalRoute.withName("/home"));
    } catch (e) {
      WeMeetToast.toast(kTranslateError(e), true);
    } finally {
      if(Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  void _flagUser() async {
    String val = await showDialog(
      context: context,
      builder: (context) => FlagUserModal()
    );

    if(val == null || val == "cancel") {
      return;
    }

    if(val == "block") {
      blockUser();
      return;
    }

    val = await showDialog(
      context: context,
      builder: (context) => ReportUserDialog()
    );
    
    if(val == null) {
      return;
    }

    reportUser(val.toUpperCase().split(" ").join("_"));
  }

  Widget buildBody() {

    if(chats.isEmpty && isLoading) {
      return WeMeetLoader.showBusyLoader(color: AppColors.color1);
    }

    if(isError && errorText != null && chats.isEmpty) {
      return WErrorComponent(text: errorText, callback: fetchChats);
    }

    if(chats.isEmpty) {
      return Center(
        child: Icon(FeatherIcons.messageSquare, size: 60.0, color: Colors.black38),
      );
    }

    return ListView.builder(
      controller: _indexScrollController,
      itemBuilder: (context, index) {
        return AutoScrollTag(
          key: ValueKey(index),
          controller: _indexScrollController,
          index: index,
          // child: buildItem(chats[index], index),
          child: ChatItem(chat: chats[index], uid: user.id),
          // highlightColor: Colors.black.withOpacity(0.1),
        );
      },
      itemCount: chats.length,
      reverse: true,
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    );
  }

  Widget buildInput() {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if(details.primaryVelocity > 0) {
          if(inputNode.hasFocus) {
            FocusScope.of(context).requestFocus(FocusNode());
          }
        } 
      },
      child: Container(
        height: 60.0,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 10.0,
          top: 10.0,
          left: 20.0,
          right: 20.0
        ),
        decoration: BoxDecoration(
          color: Color(0xfff4f4f4),
          borderRadius: BorderRadius.circular(10.0)
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: Color(0xfff4f4f4)
                ),
                child: TextField(
                  controller: inputC,
                  focusNode: inputNode,
                  textInputAction: TextInputAction.send,
                  autocorrect: false,
                  decoration: InputDecoration.collapsed(
                    hintText: "Work your magic..."
                  ),
                  onSubmitted: (val) => sendMessage(),
                ),
              ),
            ),
            GestureDetector(
              onTap: sendMessage,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xff878787),
                  borderRadius: BorderRadius.circular(10.0)
                ),
                child: Text(
                  "Send",
                  style: TextStyle(
                    color: Colors.white
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildAppBar() {
    Map u = model.matchList["$uid"] ?? {
      "name": widget.name ?? "...",
      "image": widget.avatar ?? "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png"
    };
    return AppBar(
      centerTitle: false,
      elevation: 1.0,
      title: Wrap(
        spacing: 10.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(u["image"]),
            radius: 17.0,
          ),
          Text(
            u["name"],
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w400,
              fontSize: 16.0
            ),
          )
        ],
      ),
      actions: [
        IconButton(
          onPressed: (){
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SongsPage(
                  onSelect: (val) {
                    sendMessage(content: val, type: "MEDIA");
                    Navigator.pop(context);
                  },
                ),
                fullscreenDialog: true
              )
            );
          },
          icon: Icon(FeatherIcons.music, color: Colors.black87,),
        ),
        IconButton(
          icon: Icon(FeatherIcons.flag),
          color: AppColors.orangeColor,
          onPressed: _flagUser,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return ScopedModelDescendant<AppModel>(
      builder: (context, child, m) {
        model = m;
        user = model.user;

        return Scaffold(
          appBar: buildAppBar(),
          body: Container(
            child: Column(
              children: [
                Expanded(child: buildBody(),),
                buildInput()
              ],
            ),
          ),
        );
      },
    );
  }
}