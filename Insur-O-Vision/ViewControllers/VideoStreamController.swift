//
//  VideoStreamController.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 7/20/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import UIKit
import HaishinKit
import AVFoundation
import Starscream
import CoreImage


class VideoStreamController: UIViewController {
  let streamHandler: StreamHandler

  init(_ streamHandler: StreamHandler) {
    self.streamHandler = streamHandler
    super.init(nibName: nil, bundle: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    streamHandler.startCamera()
    let hkView = GLHKView(frame: view.bounds)
    hkView.videoGravity = AVLayerVideoGravity.resizeAspectFill
    hkView.attachStream(streamHandler.rtmpStream)
    self.view.insertSubview(hkView, at: 0)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  @IBAction func flashToggle(_ sender: UIButton) {
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
  
  @IBAction func captureImage(_ sender: UIButton) {
    let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
    let _ = renderer.image { ctx in
      let renderedView = self.view.subviews[0]
      renderedView.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
    }
  }
  
  @IBAction func toggleStream(_ sender: UIButton) {
    streamHandler.startStream()
  }
  
  @IBAction func zoom(_ sender: Any) {
    streamHandler.zoom(2.0)
  }
  
}
