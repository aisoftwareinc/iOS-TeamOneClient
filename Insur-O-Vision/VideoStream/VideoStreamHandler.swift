import Foundation
import HaishinKit
import AVFoundation
import Asterism
import VideoToolbox

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
    rtmpStream.captureSettings = [
        .fps: 30, // FPS
        .sessionPreset: AVCaptureSession.Preset.hd1280x720, // input video width/height
        .continuousAutofocus: false, // use camera autofocus mode
        .continuousExposure: false, //  use camera exposure mode
        // .preferredVideoStabilizationMode: AVCaptureVideoStabilizationMode.auto
    ]
    rtmpStream.videoSettings = [
      .width: 1280,
      .height: 720,
      .bitrate: HighResolution().bitrate * 1024,
      .profileLevel: kVTProfileLevel_H264_Baseline_3_1, // H264 Profile require "import VideoToolbox"
      .maxKeyFrameIntervalDuration: 0,

    ]
    rtmpStream.attachAudio(AVCaptureDevice.default(for: AVMediaType.audio), automaticallyConfiguresApplicationAudioSession: false)
    rtmpConnection.addEventListener(Event.Name.rtmpStatus, selector: #selector(rtmpStatusEvent), observer: self)
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
        //rtmpStream.publish(calculateAppendNumber())
        rtmpStream.publish(streamID)
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
      if let orientation = DeviceUtil.videoOrientation(by: UIApplication.shared.statusBarOrientation) {
          rtmpStream.orientation = orientation
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
    isRunning = !isRunning
  }
  
  func disconnect() {
    rtmpStream.close()
    rtmpStream.dispose()
  }
  
  func updateResolution(_ resolution: Resolution) {
    let bitate = resolution.bitrate * 1024
    rtmpStream.videoSettings[.bitrate] =  bitate
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
