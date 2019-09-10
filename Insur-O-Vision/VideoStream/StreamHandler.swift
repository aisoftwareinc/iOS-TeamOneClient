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

protocol StreamVideoDelegate: class {
  func didGetLiveFeed(_ data: CMSampleBuffer)
}

class StreamHandler {
  private let sampleRate: Double = 44_100
  let rtmpConnection = RTMPConnection()
  lazy var rtmpStream = RTMPStream(connection: rtmpConnection)
  
  private var isRunning: Bool = false
  private let streamURI: String
  private let streamID: String
  
  open lazy var moviesDirectory: URL = {
    URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
  }()
  
  weak var delegate: StreamVideoDelegate?
  
  init(_ uri: String, id: String) {
    streamURI = uri
    streamID = id
    setUp()
  }
  
  private func setUp() {
    rtmpStream.syncOrientation = true
    rtmpStream.captureSettings = [
      "sessionPreset": AVCaptureSession.Preset.hd1920x1080.rawValue,
      "continuousAutofocus": true,
      "continuousExposure": true,
      "preferredVideoStabilizationMode": AVCaptureVideoStabilizationMode.auto.rawValue
    ]
    rtmpStream.videoSettings = [
      "width": 1280,
      "height": 720,
      "bitrate": HighResolution().bitrate * 1024
    ]
    rtmpStream.audioSettings = [
      "muted": false, // mute audio
      "bitrate": 32 * 1024
    ]

    rtmpStream.resume()
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
    isRunning = true
  }
  
  func stopStream() {
    rtmpStream.close()
    isRunning = false
  }
  
  func zoom(_ float: CGFloat) {
    rtmpStream.setZoomFactor(float, ramping: true, withRate: 3.0)
  }
  
  func togglePause() {
    rtmpStream.togglePause()
    isRunning = !isRunning
  }
  
  func disconnect() {
    rtmpStream.close()
    rtmpStream.dispose()
  }
  
  func updateResolution(_ resolution: Resolution) {
    let bitate = resolution.bitrate * 1024
    rtmpStream.videoSettings["bitrate"] =  bitate
  }
  
  func isStreaming() -> Bool {
    return isRunning
  }
}
