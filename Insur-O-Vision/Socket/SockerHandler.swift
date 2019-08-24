//
//  SockerHandler.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 8/11/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation
import Starscream

protocol RemoteCommandsDelegate: class {
  func didRecieveCommand(_ command: Socket.Command)
  func didDisconnect()
  func didConnect()
}

class Socket {
  
  enum Command: String {
    case zoom = "zoom"
    case flash = "flash"
    case screenShot = "screenshot"
    case stopVideo = "stop"
    case startVideo = "start"
  }
  
  weak var delegate: RemoteCommandsDelegate?
  let socket: WebSocket
  
  init(_ url: URL) {
    socket = WebSocket(url: url)
    socket.delegate = self
    socket.connect()
  }
  
  func sendMessage(_ message: String) {
    socket.write(string: message)
  }
  
  func sendData(_ data: Data) {
    socket.write(data: data)
  }

  var receivedImage: ((Data) -> Void)!
}

extension Socket: WebSocketDelegate {
  public func websocketDidConnect(socket: WebSocketClient) {
    print("Did Connect")
    delegate?.didConnect()
  }
  
  public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
    print("Did disconnect")
    delegate?.didDisconnect()
  }
  
  public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
    print("Received message: \(text)")
    if let command = Command(rawValue: text) {
      
      delegate?.didRecieveCommand(command)
      
      switch command {
      case .flash:
        print("Toggle Flash")
      case .screenShot:
        print("Toggle Screenshot")
      case .stopVideo:
        print("Toggle Stop video")
      case .startVideo:
        print("Toggle Start")
      case .zoom:
        print("Toggle Zoom")
      }
    }
  }
  
  public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
    print("Received data: \(data)")
    receivedImage(data)
  }
  
  
}
