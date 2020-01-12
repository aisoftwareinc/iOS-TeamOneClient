import UIKit
import Asterism
import AVFoundation
import Anchorage

protocol CameraViewControllerDelegate: class {
  func didCapturePhoto(_ imageData: Data, claimID: String)
}


class CameraViewController: UIViewController {
  
  let captureButton: UIButton
  let flashButton: UIButton
  weak var delegate: CameraViewControllerDelegate?
  private let claimID: String
  
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
    preview.transform = CATransform3DMakeRotation(CGFloat(-Double.pi/2), 0, 0, 1)
    return preview
  }()
  
  private let output = AVCapturePhotoOutput()
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  init(delegate: CameraViewControllerDelegate, claimID: String) {
    self.captureButton = UIButton(frame: .zero)
    self.flashButton = UIButton(frame: .zero)
    self.delegate = delegate
    self.claimID = claimID
    super.init(nibName: nil, bundle: nil)
  }
  
  deinit {
    DLOG("CameraViewController deinit")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    startCamera()
    addFlashButton()
    addCaptureButton()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
  }
  
  override func viewWillLayoutSubviews() {
    self.previewLayer.frame = self.view.bounds
    if let connection = previewLayer.connection {
      connection.videoOrientation = .portrait
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func addCaptureButton() {
    captureButton.setImage(UIImage(imageLiteralResourceName: "CaptureImage"), for: .normal)
    captureButton.addTarget(self, action: #selector(capture), for: .touchUpInside)
    captureButton.tintColor = .white
    self.view.addSubview(captureButton)
    captureButton.bottomAnchor == self.view.bottomAnchor - 50
    captureButton.centerXAnchor == self.view.centerXAnchor
    captureButton.widthAnchor == 75
    captureButton.heightAnchor == 75
    captureButton.translatesAutoresizingMaskIntoConstraints = false
    captureButton.sizeToFit()
  }
  
  private func addFlashButton() {
    flashButton.setImage(#imageLiteral(resourceName: "Flash"), for: .normal)
    flashButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
    flashButton.tintColor = .white
    self.view.addSubview(flashButton)
    flashButton.topAnchor == self.view.topAnchor + 100
    flashButton.rightAnchor == self.view.rightAnchor - 20
    flashButton.widthAnchor == 40
    flashButton.heightAnchor == 40
    flashButton.translatesAutoresizingMaskIntoConstraints = false
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
      connection.videoOrientation = .portrait
      self.output.capturePhoto(with: settings, delegate: self)
    }
  }
  
  @objc
  private func toggleFlash() {
    guard let currentDevice = captureDevice else {
      return
    }
    if currentDevice.hasTorch {
      do {
        try currentDevice.lockForConfiguration()
        currentDevice.torchMode = currentDevice.isTorchActive ? .off : .on
        currentDevice.unlockForConfiguration()
      } catch {
        print("error")
      }
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
    if let imageData = photo.fileDataRepresentation() {
      self.delegate?.didCapturePhoto(imageData, claimID: claimID)
    }
  }
}
