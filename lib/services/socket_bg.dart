import 'dart:io';
import 'dart:isolate';
import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart';

import 'package:wemeet/models/chat.dart';

Isolate isolate;

class BackgroundSocketService {

  BackgroundSocketService._internal();

  static final BackgroundSocketService _socketService = BackgroundSocketService._internal();

  factory BackgroundSocketService() {
    return _socketService;
  }

  ReceivePort _receivePort = ReceivePort();
  SendPort _isolateSendPort;

  void _sendMessage(Map val) {
    print("=== New message $val");
    if(val["action"] == "message") {
      _chatController.add(ChatModel.fromMap(val["value"]));
    }
    
  }

  void start(String baseUrl) async {
    print("====== starting isolate");
    try {
      isolate = await Isolate.spawn(_runTasks, {
        "action": "connect", 
        "value": baseUrl,
        "port": _receivePort.sendPort
      });
      isolate.addOnExitListener(_receivePort.sendPort);
      _receivePort.listen((data) {
        if(data == null){
          print("Background process exited");
        }

        if(_isolateSendPort == null && data is SendPort) {
          _isolateSendPort = data;
          return;
        }

        if(data is Map) {
          _sendMessage(data);
          return;
        }
      });
      isolate.resume(isolate.pauseCapability);
    } catch(e){
      print(e);
    }
  }

  void joinRooms(List<String> ids) {
    _isolateSendPort?.send({"action": "join-rooms", "value": ids});
  }

  void join(String room) {
    _isolateSendPort?.send({"action": "join-rooms", "value": [room]});
  }

  void resume() {
    isolate?.resume(isolate?.pauseCapability);
  }

  void stop() async {
    if (isolate != null) {
      stdout.writeln('killing isolate');
      isolate.kill(priority: Isolate.immediate);
      isolate = null;        
    }  
  }

  String _currentRoom;
  String get room => _currentRoom;

  // new chat stream controller
  StreamController<ChatModel> _chatController =
      StreamController<ChatModel>.broadcast();
  Stream<ChatModel> get onChatReceived =>
      _chatController.stream;

  // Active chat stream controller
  StreamController<String> _roomController =
      StreamController<String>.broadcast();
  Stream<String> get onRoomChanged =>
      _roomController.stream;

  void addChat(ChatModel val) {
    _chatController.add(val);
  }

  void setRoom(String val) {
    _currentRoom = val;
    _roomController.add(val);
  }
}

void _runTasks(Map arg) async {

  SendPort sendPort = arg["port"] as SendPort; // get the send port
  var isolatePort = new ReceivePort();
  sendPort.send(isolatePort.sendPort); // make sure main thread can send message

  Socket _socket;
  List<String> _rooms = [];

  // connect socket
  void _connect(String url) async {

    // send connecting message
    sendPort?.send({
      "action": "connecting",
      "value": "Socket is connecting in isolate"
    });

    _socket = io(
      url,
      OptionBuilder()
        .setTransports(['websocket'])
        // .setTimeout(20000)
        .build()
    );

    // Socket on connection
    _socket.onConnect((data) {
      sendPort?.send({
        "action": "connected",
        "value": "Socket is connected in isolate"
      });

      // join rooms
      (_rooms ?? []).forEach((room) {
        if(_rooms.contains(room)) {
          return;
        }
        _socket.emit("join", {"chatId": room});
        _rooms.add(room);
      });

      // Subscribe to new message
      _socket.on('new message', (data) {
        Map mssg = data["message"];
        if(mssg == null || mssg.isEmpty) {
          return;
        }

        // send new message received
        sendPort?.send({
          "action": "message",
          "value": mssg
        });
      });

    });

    // Socket on disconnect
    _socket.onDisconnect((data){
      sendPort?.send({
        "action": "disconnected",
        "value": "Socket is disconnected in isolate"
      });
      _rooms.clear();
    });

    _socket.on('fromServer', (_) => print(_));
  }

  // join rooms
  void joinRooms(List val) {
    // check if connection is initialiazed
    if(_socket == null || val == null || val.isEmpty){
      _connect(arg["value"]);
    }

    val.forEach((room) {
      if(_rooms.contains(room)) {
        return;
      }
      _socket.emit("join", {"chatId": room});
      _rooms.add(room);
    });
  }

  isolatePort.listen((data) {
    try {

      // if data is null
      if(data == null){
        return;
      }

      // if data does not have action
      if(data["action"] == null) {
        return;
      }

      // if connection
      if(data["action"] == "connect") {
       _connect(data["value"]);
        return;
      }

      // if join rooms
      if(data["action"] == "join-rooms") {
       joinRooms(data["value"] as List);
        return;
      }

    } catch (e) {
      print("Error occured in isolate");
    }
  });

}