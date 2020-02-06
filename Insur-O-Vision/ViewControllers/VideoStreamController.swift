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
import Asterism

class VideoStreamController: UIViewController {
  let streamHandler: VideoStreamHandler
  let socket: Socket
  private let viewModel: ViewStreamViewModel
  @IBOutlet weak var flashButton: UIButton!
  @IBOutlet weak var cameraButton: UIButton!
  @IBOutlet weak var captureButton: PrimaryButton!
  @IBOutlet weak var socketConnectionImage: UIImageView!
  
  init(_ streamHandler: VideoStreamHandler, _ claimID: String, streamID: String) {
    self.streamHandler = streamHandler
    self.viewModel = ViewStreamViewModel(claimID, streamID)
    self.socket = Socket(URL(string: "wss://demo.teamonecms.com/ws/media.ashx?streamID=\(streamID)")!)
    super.init(nibName: nil, bundle: nil)
    self.socket.delegate = self
    self.streamHandler.delegate = self
    
    NotificationCenter.default.addObserver(self, selector: #selector(killApp), name: UIApplication.didEnterBackgroundNotification, object: nil)
  }
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override func viewDidLoad() {
    self.socketConnectionImage.image = #imageLiteral(resourceName: "Socket")
    self.socketConnectionImage.tintColor = UIColor.red
    UIApplication.shared.isIdleTimerDisabled = true
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
    DLOG("Video Stream Controller Deinit")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
    super.viewWillAppear(animated)
    streamHandler.startCamera()
    buildStreamView()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    streamHandler.disconnect()
    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    viewModel.endStream()
    UIApplication.shared.isIdleTimerDisabled = false
  }
  
  @objc
  private func killApp() {
    fatalError()
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
    if let torchEnabled = viewModel.captureDevice?.torchMode {
      let result = torchEnabled == .off ? true : false
      viewModel.toggleFlash(result)
    }
  }
  
  @IBAction func captureImage(_ sender: UIButton) {
    captureScreen()
  }
  
  @IBAction func toggleStream(_ sender: UIButton) {
    switch streamHandler.isStreaming() {
    case true:
      stopStream()
    case false:
      startStream()
    }
  }
  
  @IBAction func zoom(_ sender: UISegmentedControl) {
    let zoomLevel = viewModel.zoomLevel(sender.selectedSegmentIndex)
    toggleZoom(zoomLevel)
  }

  
  func toggleZoom(_ level: CGFloat) {
    streamHandler.zoom(level)
  }
  
  func startStream() {
    streamHandler.startStream()
    viewModel.postStartStream()
  }
  
  func stopStream() {
    streamHandler.stopStream()
    viewModel.postStopStream()
  }
  
  func togglePause() {
    streamHandler.togglePause()
  }
  
  
  func captureScreen() {
    let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
    let image = renderer.image { ctx in
      let renderedView = self.view.subviews[0]
      renderedView.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
    }
    let data = image.jpegData(compressionQuality: 0.25)!
    viewModel.sendImage(data)
  }
}

extension VideoStreamController: RemoteCommandsDelegate {
  func recivedNotice(_ notice: String) {
    DLOG("Notice \(notice)")
    let alert = viewModel.presentMessage(notice)
    self.present(alert, animated: true, completion: nil)
  }
  
  func didRecieveCommand(_ command: Socket.Command) {
    DLOG("Command Received from Video Stream Controller: \(command)")
    switch command {
    case .zoomIn:
      let level = viewModel.zoomLevel(2)
      toggleZoom(level)
    case .zoomOut:
      let level = viewModel.zoomLevel(0)
      toggleZoom(level)
    case .endVideo:
      self.navigationController?.popViewController(animated: true)
    case .flashOn:
      viewModel.toggleFlash(true)
    case .flashOff:
      viewModel.toggleFlash(false)
    case .screenShot:
      captureScreen()
    }
  }
  
  func didDisconnect() {
    print("Did disconnect")
    UI { [weak self] in self?.socketConnectionImage.tintColor = UIColor.red }
  }
  
  func didConnect() {
    print("Did Connect")
    UI { [weak self] in self?.socketConnectionImage.tintColor = UIColor.green }
  }
}

extension VideoStreamController: StreamVideoDelegate {
  
  func streamFailedToConnect() {
    let alertController = UIAlertController(title: "Error", message: "Could not connect to video streaming server.", preferredStyle: .alert)
    let closeAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(closeAction)
    UI { self.present(alertController, animated: true, completion: nil) }
  }
  
  func streamStartedSuccessfully() {
    DLOG("Successfully connected to video streaming server")
    UI {
      self.captureButton.setTitle("Stop Camera", for: .normal)
      self.captureButton.backgroundColor = .red
    }
  }
  
  func streamEndedSuccessfully() {
    UI {
      self.captureButton.setTitle("Start Camera", for: .normal)
      self.captureButton.backgroundColor = Colors.primary
    }
  }
  
  func connectionClosed() {
    DLOG("Connection closed from video streaming server")
  }
  
  func invalidStreamIDProvided() {
    let alertController = UIAlertController(title: "Error", message: "Invalid Claim ID Provided", preferredStyle: .alert)
    let closeAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(closeAction)
    UI { self.present(alertController, animated: true, completion: nil) }
  }
}

