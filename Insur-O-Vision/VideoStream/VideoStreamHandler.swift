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
  func streamFailedToConnect()
  func streamStartedSuccessfully()
  func streamEndedSuccessfully()
  func invalidStreamIDProvided()
  func connectionClosed()
}

class VideoStreamHandler {
  private let sampleRate: Double = 44_100
  let rtmpConnection = RTMPConnection()
  lazy var rtmpStream = RTMPStream(connection: rtmpConnection)
  
  private var isRunning: Bool = false
  private let streamURI: String
  private let streamID: String
  private var baseNumber: Int = 0
  
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
      "preferredVideoStabilizationMode": AVCaptureVideoStabilizationMode.standard.rawValue
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
    rtmpConnection.addEventListener(Event.RTMP_STATUS, selector: #selector(rtmpStatusEvent), observer: self)
  }
  
  @objc
  func rtmpStatusEvent(_ status: Notification) {
      let e = Event.from(status)
      guard
          let data: ASObject = e.data as? ASObject,
          let code: String = data["code"] as? String else {
          return
      }
      switch code {
      case RTMPConnection.Code.connectSuccess.rawValue:
        rtmpStream.publish("8d10a605")
        isRunning = true
        DLOG("Connection Success!")
      case RTMPConnection.Code.connectClosed.rawValue:
        DLOG("Connection Closed")
        self.delegate?.connectionClosed()
      case RTMPConnection.Code.connectFailed.rawValue:
        self.delegate?.streamFailedToConnect()
        DLOG("Connection Failed")
      case RTMPConnection.Code.connectIdleTimeOut.rawValue:
        DLOG("Connection Timedout")
      case RTMPStream.Code.unpublishSuccess.rawValue:
        DLOG("Stream Unpublished")
        rtmpConnection.close()
        self.delegate?.streamEndedSuccessfully()
        baseNumber += 1
        isRunning = false
      case RTMPStream.Code.publishStart.rawValue:
        DLOG("Stream Published")
        self.delegate?.streamStartedSuccessfully()
      case RTMPStream.Code.failed.rawValue:
        DLOG("Stream Failed!")
      case RTMPStream.Code.publishBadName.rawValue:
        DLOG("Incorrect Stream ID Provided")
        self.delegate?.invalidStreamIDProvided()
      default:
        DLOG("Unhandled Code: \(code)")
      }
  }
  
  func startCamera() {
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setPreferredSampleRate(sampleRate)
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
    isRunning = true
  }
  
  func stopStream() {
    rtmpStream.close()
  }
  
  func zoom(_ float: CGFloat) {
    rtmpStream.setZoomFactor(float, ramping: true, withRate: 3.0)
  }
  
  func togglePause() {
   // rtmpStream.togglePause()
    isRunning = !isRunning
  }
  
  func disconnect() {
    rtmpStream.close()
    rtmpStream.dispose()
  }
  
  func updateResolution(_ resolution: Resolution) {
    let bitate = resolution.bitrate * 1024
    rtmpStream.videoSettings["bitrate"] =  bitate
    DLOG("Updating Resolution to: \(bitate)")
  }
  
  func isStreaming() -> Bool {
    return isRunning
  }
  
  
}

extension VideoStreamHandler {
  func calculateAppendNumber() -> String {
    let updatedID = baseNumber == 0 ? streamID : streamID + "_\(baseNumber)"
    return updatedID
  }
}
