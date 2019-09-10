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
  private let viewModel: ViewStreammViewModel
  @IBOutlet weak var flashButton: UIButton!
  @IBOutlet weak var cameraButton: UIButton!
  @IBOutlet weak var captureButton: PrimaryButton!
  @IBOutlet weak var socketConnectionImage: UIImageView!
  @IBOutlet weak var resolutionButton: UIButton!
  
  init(_ streamHandler: StreamHandler, _ streamID: String) {
    self.streamHandler = streamHandler
    self.viewModel = ViewStreammViewModel(streamID)
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
                                           using: { _ in
                                            switch UIDevice.current.orientation {
                                            case .landscapeLeft, .landscapeRight:
                                              print("landscape")
                                            case .portrait, .portraitUpsideDown:
                                              print("Portrait")
                                            default:
                                              print("other")
                                            }
                                            
    })
    self.socketConnectionImage.image = #imageLiteral(resourceName: "Socket")
    self.socketConnectionImage.tintColor = UIColor.red
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
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
    viewModel.toggleFlash()
  }
  
  @IBAction func captureImage(_ sender: UIButton) {
    captureScreen()
  }
  
  @IBAction func toggleStream(_ sender: UIButton) {
    switch streamHandler.isStreaming() {
    case true:
      stopStream()
      captureButton.setTitle("  Start  ", for: .normal)
    case false:
      startStream()
      captureButton.setTitle("  Stop  ", for: .normal)
    }
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
  
  
  func captureScreen() {
    let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
    let image = renderer.image { ctx in
      let renderedView = self.view.subviews[0]
      renderedView.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
    }
    let data = image.jpegData(compressionQuality: 0.25)!
    //socket.sendData(data)
    let base64Image = data.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .urlEncoded)!
    Networking.send(request: SendImageRequest("999999", base64Image: base64Image)) {  (result: Result<RegisterPushResult, Error>) in
      
    }
  }
  
  @IBAction func updateResolution(_ sender: Any) {
    let alertController = UIAlertController(title: "Stream Quality", message: "Change Resolution", preferredStyle: .actionSheet)
    let highBitrate = UIAlertAction(title: "High", style: .default, handler: { [unowned self] _ in self.streamHandler.updateResolution(HighResolution()) })
    let defaultBitrate = UIAlertAction(title: "Medium", style: .default, handler: { [unowned self] _ in self.streamHandler.updateResolution(DefaultResolution()) })
    let lowBitrate = UIAlertAction(title: "Low", style: .default, handler: { [unowned self] _ in self.streamHandler.updateResolution(LowResolution()) })
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alertController.addAction(highBitrate)
    alertController.addAction(defaultBitrate)
    alertController.addAction(lowBitrate)
    alertController.addAction(cancel)
    present(alertController, animated: true, completion: nil)
  }
}

extension VideoStreamController: RemoteCommandsDelegate {
  func didRecieveCommand(_ command: Socket.Command) {
    switch command {
    case .flash:
      viewModel.toggleFlash()
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
    UI { [weak self] in self?.socketConnectionImage.tintColor = UIColor.red }
  }
  
  func didConnect() {
    print("Did Connect")
    UI { [weak self] in self?.socketConnectionImage.tintColor = UIColor.green }
  }
}

extension CharacterSet {
  static let urlEncoded: CharacterSet = {
    let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
    let subDelimitersToEncode = "!$&'()*+,;="
    var allowed = CharacterSet.urlQueryAllowed
    allowed.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)
    return allowed
  }()
}
