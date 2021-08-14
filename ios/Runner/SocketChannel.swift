//
//  SocketChannel.swift
//  Runner
//
//  Created by Mehdi Sohrabi on 8/12/19.
//  Copyright © 2019 REKAB. All rights reserved.
//

import UIKit

class SocketChannel: NSObject {
    var socketChannel: FlutterMethodChannel!

    init(_ window: UIWindow?) {
        super.init()
        
        let controller = window?.rootViewController as! FlutterViewController
        self.socketChannel = FlutterMethodChannel(name: "flutter_socket_io",
                                                  binaryMessenger: controller)
        
        
        self.socketChannel.setMethodCallHandler { [weak self] (call, result) in
            let args = call.arguments as! NSDictionary
            
            let socketNameSpace: String = args[SOCKET_NAME_SPACE] as! String
            let socketDomain: String = args[SOCKET_DOMAIN] as! String
            let callback = args[SOCKET_CALLBACK] as? String
            
            if SOCKET_INIT == call.method {
                let query = args[SOCKET_QUERY] as? String
                var queryStringDictionary = Dictionary<String, String>()
                if let urlComponents = query?.components(separatedBy: "&") {
                    for keyValuePair in urlComponents {
                        let pairComponents = keyValuePair.components(separatedBy: "=")
                        let key: String = pairComponents.first!.removingPercentEncoding!
                        let value: String = pairComponents.last!.removingPercentEncoding!
                        
                        queryStringDictionary[key] = value
                    }
                }
                
                SocketIOManager.shared()?.initSocket(self?.socketChannel,
                                                     domain: socketDomain,
                                                     query: queryStringDictionary,
                                                     namspace: socketNameSpace,
                                                     callBackStatus: callback)
                
            } else if SOCKET_CONNECT == call.method {
                SocketIOManager.shared()?.connectSocket(socketDomain, namspace: socketNameSpace)
            } else if SOCKET_DISCONNECT == call.method {
                SocketIOManager.shared()?.disconnectDomain(socketDomain, namspace: socketNameSpace)
            } else if SOCKET_SUBSCRIBES ==  call.method {
                let socketData = args[SOCKET_DATA] as! String
                let data = socketData.data(using: String.Encoding.utf8)
                let map = try? JSONSerialization.jsonObject(with: data!, options: []) as? NSMutableDictionary
                SocketIOManager.shared()?.subscribes(socketDomain, namspace: socketNameSpace, subscribes: map)
            } else if SOCKET_UNSUBSCRIBES == call.method {
                let socketData = args[SOCKET_DATA] as! String
                let data = socketData.data(using: String.Encoding.utf8)
                let map = try? JSONSerialization.jsonObject(with: data!, options: []) as? NSMutableDictionary
                SocketIOManager.shared()?.unSubscribes(socketDomain, namspace: socketNameSpace, subscribes: map)
            } else if SOCKET_UNSUBSCRIBES_ALL == call.method {
                SocketIOManager.shared()?.unSubscribesAll(socketDomain, namspace: socketNameSpace)
            } else if SOCKET_SEND_MESSAGE == call.method {
                print("SOCKET_SEND_MESSAGE native");
                let event = args[SOCKET_EVENT] as? String
                let message = args[SOCKET_MESSAGE] as? String
                if event != nil && message != nil {
                    SocketIOManager.shared()?.sendMessage(event!, message: message!, domain: socketDomain, namspace: socketNameSpace, callBackStatus: callback)
                }
            } else if SOCKET_DESTROY == call.method {
                SocketIOManager.shared()?.destroySocketDomain(socketDomain, namspace: socketNameSpace)
            } else if SOCKET_DESTROY_ALL == call.method {
                SocketIOManager.shared()?.destroyAllSocket()
            } else {
                result(FlutterMethodNotImplemented);
            }
        }
    }
    
    func dispose() {
        SocketIOManager.shared()?.destroyAllSocket()
    }
}