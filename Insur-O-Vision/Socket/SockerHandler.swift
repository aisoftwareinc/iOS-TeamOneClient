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
    case zoomIn = "zoomin"
    case zoomOut = "zoomout"
    case endVideo = "endvideo"
    case flashOn = "flashlighton"
    case flashOff = "flashlightoff"
    case screenShot = "photo"
    case resolution480 = "resolution480"
    case resolution720 = "resolution720"
    case resolution1080 = "resolution1080"
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
        case .zoomIn:
        DLOG("Toogle Zoom In")
        case .zoomOut:
        DLOG("Toggle Zoom out")
        case .endVideo:
        DLOG("Toggle End Video")
        case .flashOn:
        DLOG("Toggle Flash On")
        case .flashOff:
        DLOG("Toggle Flash off")
        case .screenShot:
        DLOG("Take Photo")
        case .resolution480:
        DLOG("resolution480")
        case .resolution720:
        DLOG("resolution720")
        case .resolution1080:
        DLOG("resolution1080")
      }
    }
  }
  
  public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
    print("Received data: \(data)")
    receivedImage(data)
  }
  
  
}
