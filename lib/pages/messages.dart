import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wemeet/components/loader.dart';
import 'dart:async';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/user.dart';
import 'package:wemeet/models/chat.dart';

import 'package:wemeet/services/message.dart';
import 'package:wemeet/services/match.dart';
import 'package:wemeet/services/socket_bg.dart';
import 'package:wemeet/utils/colors.dart';

import 'package:wemeet/utils/errors.dart';

import 'package:wemeet/components/search_field.dart';
import 'package:wemeet/components/error.dart';
import 'package:wemeet/components/message_item.dart';

class MessagesPage extends StatefulWidget {
  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {

  bool isLoading = false;
  bool isError = false;
  String errorText;
  List<ChatModel> items = [];
  String query = "";

  BackgroundSocketService socketService = BackgroundSocketService();

  StreamSubscription<ChatModel> onChatMessage;
  StreamSubscription<String> onRoom;
  Timer _debounce;

  AppModel model;
  UserModel user;

  @override
  void initState() { 
    super.initState();

    onChatMessage = socketService?.onChatReceived?.listen(onChatReceive);
    onRoom = socketService?.onRoomChanged?.listen(onRoomChanged);
    
    fetchChats();
  }

  @override
  void dispose() {
    onChatMessage?.cancel();
    onRoom?.cancel();
    super.dispose();
  }

  void getDbChats() async {
    await Future.delayed(Duration(milliseconds: 100));
    Map cL = model.chatList ?? {};
    Map mL = model.matchList ?? {};

    List<ChatModel> ic = [];

    // fix broken values
    cL.forEach((k, v) {
      if(!(v is Map)) {
        v = {
          "message": "...",
          "timestamp": v
        };
        cL[k] = v;
      }

      int t = v["timestamp"];
      
      String m = k.toString().split("_").firstWhere((e) => e != user.id.toString(), orElse: () => user.id.toString());

      Map match = mL[m];

      if(match != null) {
        ChatModel c = ChatModel(
          chatId: k,
          content: v["message"],
          type: "TEXT",
          sentAt: (t is int && t != 0) ? DateTime.fromMillisecondsSinceEpoch(t) : DateTime.now().toLocal()
        );

        c.avatar = match["image"];
        c.name = match["name"];
        ic.add(c);
      }
    });

    // update chatList
    model.setChatList(cL);

    setState(() {
      items = ic;      
    });

  }

  void fetchChats() async {

    await getDbChats();

    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {
      var res = await MessageService.getChats();
      List data = res["data"]["messages"];
      // print(data);
      setState(() {
        items = data.map((e) => ChatModel.fromMap(e)).toList();
      });
      _prepareChatList();

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

  void _prepareChatList() {

    Map cL = model.chatList ?? {};

    items.forEach((e) { 

      cL[e.chatId] = {
        "message": (e.type == "TEXT") ? e.content : "audio...",
        "timestamp": (!cL.containsKey(e.chatId)) ? e.timestamp : (cL[e.chatId]["timestamp"] ?? 0)
      };
    });

    model.setChatList(cL);
    socketService.joinRooms(items.map((e) => e.chatId).toList());
  }

  void getMatch(int id) {
    if(id == user.id) {
      return;
    }

    if(model.matchList.containsKey("$id")) {
      return;
    }

    MatchService.getMatches().then((res){
      List data = res["data"]["content"] as List;

      Map mtL = model.matchList ?? {};

      data.map((e) => UserModel.fromMap(e)).toList().forEach((u) {
        mtL["${u.id}"] = {"name": u.fullName, "image": u.profileImage};
      });

      model.setMatchList(mtL);
    });
  }

  void onChatReceive(ChatModel chat) {
    if (!mounted) {
      return;
    }

    int i = items.indexWhere((el) => el.chatId == chat.chatId);

    setState(() {
      if (i >= 0) {
        items[i] = chat;
      } else {
        items.add(chat);
      }
    });

    // update chatList if in the same room
    if(chat.chatId == socketService.room) {
      Map cL = model.chatList;
      cL[chat.chatId] = {
        "message": (chat.type == "TEXT") ? chat.content : "audio...",
        "timestamp": chat.timestamp
      };
    }

    // check if user is a match
    getMatch(chat.senderId == user.id ? chat.receiverId : chat.senderId);
  }

  void onRoomChanged(String roomId) {
    if (!mounted || roomId == null) {
      return;
    }

    print("Room changed");

    int index = items.indexWhere((el) {
      // if chatId matches
      if (roomId == el.chatId) {
        return true;
      }

      return false;
    });

    if (index >= 0) {
      Map cL = model.chatList;
      cL[roomId]["timestamp"] = DateTime.now().toLocal().millisecondsSinceEpoch; //items[index].timestamp;
      setState(() {
        items[index].withBubble = false;
      });
      model.setChatList(cL);
    }
  }

  void search(String val){

    //Delay Api call by a second
    bool active = _debounce?.isActive ?? false;
    if (active) {
      _debounce.cancel();
    } 
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if(!mounted) return;
      setState(() {
        query = val;        
      });;
    });
  }

  List<ChatModel> get chats {

    if(items.isEmpty) {
      return [];
    }

    Map mcL = model.chatList ?? {};
    Map mtL = model.matchList ?? {};
    List<ChatModel> i = items;

    i.forEach((el) { 

      int u = (el.senderId == user.id) ? el.receiverId : el.senderId;

      // get the matches
      if(mtL.containsKey(u.toString())) {
        el.avatar = mtL["$u"]["image"];
        el.name = mtL["$u"]["name"];
      }

      // make sure there is no bubble if user sent the last message
      if(el.senderId == user.id) {
        el.withBubble = false;
        return;
      }

      // check if key is present
      if(mcL.containsKey(el.chatId)){
        el.withBubble = (el.timestamp > mcL[el.chatId]["timestamp"] && el.senderId != user.id);
      }

    });

    i.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    i.retainWhere((e) => e.avatar != null);

    return i.where((e){
      if(query == null || query.isEmpty) return true;

      String name = e.name.toLowerCase();
      return name.contains(query.toLowerCase());

    }).toList();

  }

  Widget buildList() {
    return ListView.separated(
      itemBuilder: (context, index) => MessageItem(message: chats[index], uid: user.id,),
      separatorBuilder: (context, index) => Divider(indent: 80.0,),
      itemCount: chats.length,
      padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    );
  }

  Widget buildBody() {
    if(isLoading && chats.isEmpty) {
      return WeMeetLoader.showBusyLoader(color: AppColors.color1);
    }

    if(isError && chats.isEmpty) {
      return WErrorComponent(text: errorText, callback: fetchChats,);
    }

    if(chats.isEmpty) {
      return Center(
        child: Icon(FeatherIcons.messageSquare, size: 60.0, color: Colors.black38),
      );
    }

    return buildList();
  }

  Widget buildAppBar() {
    return AppBar(
      title: Text("Messages"),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: WSearchField(
            hintText: "Search by name",
            onChanged: search,
          ),
        ),
      ),
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
          body: buildBody(),
        );
      }
    );
  }
}