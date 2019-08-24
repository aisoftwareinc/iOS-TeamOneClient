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
import Anchorage

class VideoStreamController: UIViewController {
  let streamHandler: StreamHandler
  let socket: Socket
  @IBOutlet weak var flashButton: UIButton!
  @IBOutlet weak var cameraButton: UIButton!
  @IBOutlet weak var captureButton: PrimaryButton!
  @IBOutlet weak var socketConnectionImage: UIImageView!
  @IBOutlet weak var resolutionButton: UIButton!
  
  init(_ streamHandler: StreamHandler) {
    self.streamHandler = streamHandler
    self.socket = Socket(URL(string: "wss://echo.websocket.org")!)
    super.init(nibName: nil, bundle: nil)
    self.socket.delegate = self
  }
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override func viewDidLoad() {
    NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification,
                                           object: nil,
                                           queue: .main,
                                           using: toggleOritenation)
    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
    self.socketConnectionImage.image = #imageLiteral(resourceName: "Socket")
    self.socketConnectionImage.tintColor = UIColor.red
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    streamHandler.startCamera()
    buildStreamView()
    socket.receivedImage = receivedData
  }
  
  @objc
  private func toggleOritenation(_ notification: Notification) {
    switch UIDevice.current.orientation {
    case .landscapeLeft, .landscapeRight:
      print("landscape")
    case .portrait, .portraitUpsideDown:
      print("Portrait")
    default:
      print("other")
    }
  }
  
  private func buildStreamView() {
    let hkStreamView = GLHKView(frame: .zero)
    view.insertSubview(hkStreamView, at: 0)
    hkStreamView.rightAnchor == view.rightAnchor
    hkStreamView.topAnchor == view.topAnchor
    hkStreamView.bottomAnchor == view.bottomAnchor
    hkStreamView.leftAnchor == view.leftAnchor
    hkStreamView.videoGravity = AVLayerVideoGravity.resizeAspectFill
    hkStreamView.attachStream(streamHandler.rtmpStream)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  @IBAction func flashToggle(_ sender: UIButton) {
    toggleFlash()
  }
  
  @IBAction func captureImage(_ sender: UIButton) {
    captureScreen()
  }
  
  @IBAction func toggleStream(_ sender: UIButton) {
    startStream()
  }
  
  @IBAction func zoom(_ sender: UISegmentedControl) {
    var zoomLevel: CGFloat
    switch sender.selectedSegmentIndex {
    case 0:
      zoomLevel = 1.0
    case 1:
      zoomLevel = 1.5
    case 2:
      zoomLevel = 2.0
    default:
      zoomLevel = 1.0
    }
    toggleZoom(zoomLevel)
  }
  
  func receivedData(_ data: Data) {
    let image = UIImage.init(data: data)!
    let imageController = TestImageViewController(image)
    present(imageController, animated: true, completion: nil)
  }
  
  func toggleZoom(_ level: CGFloat) {
    streamHandler.zoom(level)
  }
  
  func startStream() {
    streamHandler.startStream()
  }
  
  func stopStream() {
    streamHandler.stopStream()
  }
  
  func togglePause() {
    streamHandler.togglePause()
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
  
  func captureScreen() {
    let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
    let image = renderer.image { ctx in
      let renderedView = self.view.subviews[0]
      renderedView.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
    }
    let data = image.jpegData(compressionQuality: 0.25)!
    socket.sendData(data)
  }
  
  @IBAction func updateResolution(_ sender: Any) {
    streamHandler.updateResolution(HighResolution())
  }
}

extension VideoStreamController: RemoteCommandsDelegate {
  func didRecieveCommand(_ command: Socket.Command) {
    switch command {
    case .flash:
      print("Toggle Flash")
      toggleFlash()
    case .screenShot:
      print("Toggle Screenshot")
      captureScreen()
    case .stopVideo:
      print("Toggle Stop video")
    case .startVideo:
      print("Toggle Start")
    case .zoom:
      print("Toggle Zoom")
      toggleZoom(2.0)
    }
  }
  
  func didDisconnect() {
    print("Did disconnect")
    UI { self.socketConnectionImage.tintColor = UIColor.red }
  }
  
  func didConnect() {
    print("Did Connect")
    UI { self.socketConnectionImage.tintColor = UIColor.green }
  }
}

