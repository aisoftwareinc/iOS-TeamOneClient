//
//  VideoStreamViewModel.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 8/30/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation
import AVFoundation
import Asterism
import UIKit

class ViewStreamViewModel {
  let claimID: String
  let streamID: String
  
  private var streamTracker = 0
  private var streamIDs = [String]()
  
  lazy var captureDevice: AVCaptureDevice? = {
    return AVCaptureDevice.default(for: AVMediaType.video)
  }()
  
  init(_ claimID: String, _ streamID: String) {
    self.claimID = claimID
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
        currentDevice.unlockForConfiguration()
      } catch {
        print("error")
      }
    }
  }
  
  func endStream() {
    Networking.send(EndStreamRequest(streamID, buildEndSessionStreams()))
  }
  
  func sendImage(_ data: Data) {
    let base64Image = data.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .urlImageEncoded)!
    Networking.send(SendImageRequest(claimID: claimID, base64Image: base64Image, photoID: "0", title: "", caption: "")) { (result: Result<NoResponse, Error>) in
      
    }
  }
  
  func postStartStream() {
    let adjustedStreamID = addStreamID()
    streamIDs.append(adjustedStreamID)
    Networking.send(StartVideoSession(streamID: adjustedStreamID))
    streamTracker += 1
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
  
  func presentMessage(_ message: String) -> UIAlertController {
    let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
    let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(dismiss)
    return alert
  }
  
  private func addStreamID() -> String {
    if streamTracker == 0 {
      return streamID
    }
    return streamID + "_\(streamTracker)"
  }
  
  private func buildEndSessionStreams() -> String {
    var streams: String = ""
    streamIDs.forEach {
      streams += $0 + ","
    }
    return String(streams.dropLast(1))
  }
}
