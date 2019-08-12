//
//  ViewController.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 7/20/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import UIKit
import HaishinKit
import AVFoundation

class ViewController: UIViewController {

  let rtmpConnection = RTMPConnection()
  lazy var rtmpStream = RTMPStream(connection: rtmpConnection)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setPreferredSampleRate(44_100)
      try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
      try session.setMode(AVAudioSession.Mode.default)
      try session.setActive(true)
      DispatchQueue.main.async { self.startRTMP() }
    } catch {
    }
  }
  
  func startRTMP() {
    rtmpStream.attachAudio(AVCaptureDevice.default(for: AVMediaType.audio)) { error in
      // print(error)
    }
    rtmpStream.attachCamera(DeviceUtil.device(withPosition: .back)) { error in
      // print(error)
    }
    
    let hkView = GLHKView(frame: view.bounds)
    hkView.videoGravity = AVLayerVideoGravity.resizeAspectFill
    
    hkView.attachStream(rtmpStream)
    
    // add ViewController#view
    view.insertSubview(hkView, at: 0)
  }

  @IBAction func startStream(_ sender: UIButton) {
    rtmpConnection.connect("rtmp://ec2-3-17-179-2.us-east-2.compute.amazonaws.com/LiveApp/")
    rtmpStream.publish("bobSacamano")
  }
  
}

