//
//  StreamHandler.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 7/20/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation
import HaishinKit
import AVFoundation

class StreamHandler {
  private let sampleRate: Double = 44_100
  let rtmpConnection = RTMPConnection()
  lazy var rtmpStream = RTMPStream(connection: rtmpConnection)
  
  private let streamURI: String
  private let streamID: String
  
  open lazy var moviesDirectory: URL = {
    URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
  }()
  
  init(_ uri: String, id: String) {
    streamURI = uri
    streamID = id
    setUp()
  }
  
  private func setUp() {
    rtmpStream.syncOrientation = true
    rtmpStream.captureSettings = [
      "sessionPreset": AVCaptureSession.Preset.hd1280x720.rawValue,
      "continuousAutofocus": true,
      "continuousExposure": true,
      "preferredVideoStabilizationMode": AVCaptureVideoStabilizationMode.auto.rawValue
    ]
    rtmpStream.videoSettings = [
      "width": 720,
      "height": 1280
    ]
    rtmpStream.audioSettings = [
      "sampleRate": sampleRate
    ]
  }
  
  func startCamera() {
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setPreferredSampleRate(44_100)
      try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
      try session.setMode(AVAudioSession.Mode.default)
      try session.setActive(true)
      rtmpStream.attachAudio(AVCaptureDevice.default(for: AVMediaType.audio)) { error in
        // print(error)
      }
      rtmpStream.attachCamera(DeviceUtil.device(withPosition: .back)) { error in
        // print(error)
      }
    } catch {
    }
  }
  
  func startStream() {
    rtmpConnection.connect(streamURI)
    rtmpStream.publish(streamID)
  }
}
