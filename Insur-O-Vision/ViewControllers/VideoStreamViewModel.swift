//
//  VideoStreamViewModel.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 8/30/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation
import AVFoundation

class ViewStreamViewModel {
  let streamID: String
  
  lazy var captureDevice: AVCaptureDevice? = {
    return AVCaptureDevice.default(for: AVMediaType.video)
  }()
  
  init(_ streamID: String) {
    self.streamID = streamID
  }
  
  func toggleFlash(_ torchOn: Bool) {
    guard let currentDevice = captureDevice else {
      return
    }
    if currentDevice.hasTorch {
      do {
        try currentDevice.lockForConfiguration()
        currentDevice.torchMode = torchOn ? .on : .off
        //try currentDevice.setTorchModeOn(level: 1.0)//Or whatever you want
        currentDevice.unlockForConfiguration()
      } catch {
        print("error")
      }
    }
  }
  
  func endStream() {
    Networking.send(EndStreamRequest(streamID)) { (result: Result<NoResponse, Error>) in
      
    }
  }
  
  func postStreamID(antMediaID: String) {
    Networking.send(PostStreamRequest(streamID, antMediaID)) { (result: Result<NoResponse, Error>) in
      
    }
  }
  
  func sendImage(_ data: Data) {
    let base64Image = data.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .urlImageEncoded)!
    Networking.send(SendImageRequest(streamID, base64Image: base64Image)) { (result: Result<NoResponse, Error>) in
      
    }
  }
  
  func zoomLevel(_ selectMode: Int) -> CGFloat {
    var zoomLevel: CGFloat
    switch selectMode {
    case 0:
      zoomLevel = 1.0
    case 1:
      zoomLevel = 1.5
    case 2:
      zoomLevel = 2.0
    default:
      zoomLevel = 1.0
    }
    return zoomLevel
  }
}
