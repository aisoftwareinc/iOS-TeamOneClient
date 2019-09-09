//
//  VideoStreamViewModel.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 8/30/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation
import AVFoundation

class ViewStreammViewModel {
  let streamID: String
  
  init(_ streamID: String) {
    self.streamID = streamID
  }
  
  func toggleFlash() {
    if let currentDevice = AVCaptureDevice.default(for: AVMediaType.video), currentDevice.hasTorch {
      do {
        try currentDevice.lockForConfiguration()
        let torchOn = !currentDevice.isTorchActive
        try currentDevice.setTorchModeOn(level: 1.0)//Or whatever you want
        currentDevice.torchMode = torchOn ? .on : .off
        currentDevice.unlockForConfiguration()
      } catch {
        print("error")
      }
    }
  }
  
  func endStream() {
    Networking.send(request: EndStreamRequest(streamID)) { (result: Result<RegisterPushResult, Error>) in
      
    }
  }
}
