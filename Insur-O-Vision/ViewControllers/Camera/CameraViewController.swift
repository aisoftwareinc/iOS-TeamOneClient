import UIKit
import Asterism
import AVFoundation
import Anchorage

class CameraViewController: UIViewController {
  
  let captureButton: UIButton
  
  private lazy var videoDataOutput: AVCaptureVideoDataOutput = {
    let output = AVCaptureVideoDataOutput()
    output.alwaysDiscardsLateVideoFrames = true
    output.setSampleBufferDelegate(self, queue: .global())
    output.connection(with: .video)?.isEnabled = true
    return output
  }()
  
  private lazy var captureDevice: AVCaptureDevice? = {
    AVCaptureDevice.default(for: .video)
  }()
  
  private lazy var session: AVCaptureSession = {
    let sess = AVCaptureSession()
    sess.sessionPreset = .hd1920x1080
    return sess
  }()
  
  private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
    let preview = AVCaptureVideoPreviewLayer(session: session)
    preview.videoGravity = .resizeAspectFill
    return preview
  }()
  
  private let output = AVCapturePhotoOutput()
  
  init() {
    self.captureButton = UIButton(frame: .zero)
    super.init(nibName: nil, bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    startCamera()
    addCaptureButton()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func addCaptureButton() {
    captureButton.setTitle("Capture", for: .normal)
    captureButton.addTarget(self, action: #selector(capture), for: .touchUpInside)
    self.view.addSubview(captureButton)
    captureButton.bottomAnchor == self.view.bottomAnchor - 50
    captureButton.centerXAnchor == self.view.centerXAnchor
    captureButton.translatesAutoresizingMaskIntoConstraints = false
    captureButton.sizeToFit()
  }
  
  private func startCamera() {
    self.previewLayer.masksToBounds = true
    self.view.layer.insertSublayer(previewLayer, below: captureButton.layer)
    self.previewLayer.frame = self.view.frame
    do {
      guard let captureDevice = captureDevice else {
        fatalError("Camera doesn't work on the simulator! You have to test this on an actual device!")
      }
      let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
      session.addInput(deviceInput)
      session.addOutput(output)
      session.startRunning()
    } catch let error {
      DLOG("Camera Error: \(error.localizedDescription)")
    }
  }
  
  @objc
  private func capture() {
    if let connection = self.output.connection(with: .video) {
      let settings = AVCapturePhotoSettings()
      let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
      let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                           kCVPixelBufferWidthKey as String: 160,
                           kCVPixelBufferHeightKey as String: 160]
      settings.previewPhotoFormat = previewFormat
      self.output.capturePhoto(with: settings, delegate: self)
    }
  }
  
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    
  }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    DLOG("Photo Captured")
  }
}
