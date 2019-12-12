//
//  AppCoordinator.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 8/9/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation
import UIKit
import Asterism

class AppCoordinator {
  
  enum ErrorState: String {
    case loginFail = "Please try login and password again."
    case genericError = "An error occured. Try Again."
    case serverError = "An error occured communicating with server."
    case emailValidationError = "Only valid email addresses can be used."
    case errorFetchingLaims = "An error occurred fetching claims."
    case errorRemovingClaim = "An error occurred removing claim. Try again."
    case emptyPassword = "Please enter valid password."
    case failedToValidateStreamID = "Claim ID not valid."
    case failedToUploadImage = "Failed to Upload Image."
    case failedToFetchImage = "Failed to Fetch Image."
  }
  
  private let locationManager = LocationManager()
  var baseController: UINavigationController!
  
  func start() -> UIViewController {
    let initialController = Configuration.didSeeEULA ? appModeSelectionController() : eulaController()
    baseController = UINavigationController(rootViewController: initialController)
    baseController.navigationBar.isTranslucent = true
    locationManager.start()
    return baseController
  }
  
  private func dashboardController() -> DashBoardController {
    return DashBoardController(delegate: self)
  }
  
  private func eulaController() -> EULAController {
    return EULAController(delegate: self)
  }
  
  private func videoStreamController(_ claimID: String, _ streamID: String, streamURL: String) -> VideoStreamController {
    return VideoStreamController(VideoStreamHandler(streamURL, id: streamID), claimID)
  }
  
  private func appModeSelectionController() -> ModeSelectionController {
    return ModeSelectionController(self)
  }
  
  private func loginViewController() -> LoginViewController {
    return LoginViewController(self)
  }
  
  private func claimsController(_ id: String, name: String) -> ClaimsListController {
    return ClaimsListController(id, self, name)
  }
  
  private func searchController(_ userID: String) -> SearchController {
    return SearchController(userID, self)
  }
  
  private func cameraController(_ claimID: String) -> CameraViewController {
    return CameraViewController(delegate: self, claimID: claimID)
  }
  
  private func imagePreviewController(_ data: Data, title: String?, notes: String?, claimID: String) -> PreviewNotesViewController {
    return PreviewNotesViewController(data, claimID, title: title, notes: notes, delegate: self)
  }
  
  private func notesController(_ notes: String?, callback: @escaping NotesCallback) -> NotesController {
    return NotesController(callback, notes)
  }
  
  private func imageListController(_ claimID: String) -> ImageListController {
    return ImageListController(claimID, self)
  }
}

extension AppCoordinator {
  func displayError(_ state: ErrorState) {
    let alertController = UIAlertController(title: "Error", message: state.rawValue, preferredStyle: .alert)
    let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
    alertController.addAction(action)
    let controllerToAlert = self.baseController.presentedViewController ?? self.baseController
    UI { controllerToAlert!.present(alertController, animated: true, completion: nil) }
  }
}

// MARK: EULADelegate
extension AppCoordinator: EULADelegate {
  func didAccept() {
    Configuration.save(true)
    self.baseController.pushViewController(appModeSelectionController(), animated: true)
  }
  
  func didCancel() {
    fatalError("User canceled!")
  }
}

// MARK: DashboardDelegate
extension AppCoordinator: DashboardDelegate {
  func onlyNumbers() {
    let alertController = UIAlertController.init(title: "Error", message: "Claim number can only be numbers.", preferredStyle: .alert)
    let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
    alertController.addAction(ok)
    baseController.present(alertController, animated: true, completion: nil)
  }
  
  func didEnterClaimsNumber(_ streamID: String, _ dashboardController: DashBoardController) {
    UI { dashboardController.updateButton(.verifying) }
    Networking.send(ValidateStreamRequest(latitude: String(locationManager.currentLocation!.coordinate.latitude), longitude: String(locationManager.currentLocation!.coordinate.longitude), streamID: streamID, modelName: UIDevice.current.model, modelNumber: "", softwareVersion: UIDevice.current.systemVersion, carrier: "")) { (result: Result<ValidateStreamResponse, Error>) in
      switch result {
      case .success(let response):
        switch response.result {
        case .success:
          UI {
            dashboardController.updateButton(.initial)
            self.baseController.pushViewController(self.videoStreamController(streamID, streamID, streamURL: Configuration.streamURL), animated: true)
          }
        case .failure:
          UI { dashboardController.updateButton(.initial) }
          self.displayError(.failedToValidateStreamID)
        }
      case .failure:
        UI { dashboardController.updateButton(.initial) }
        self.displayError(.genericError)
      }
    }
  }
  
  func noClaimNumberEntered() {
    let alertController = UIAlertController.init(title: "Error", message: "Please enter a claim number.", preferredStyle: .alert)
    let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
    alertController.addAction(ok)
    baseController.present(alertController, animated: true, completion: nil)
  }
}

// MARK: ModeSelectionDelegate

extension AppCoordinator: ModeSelectionDelegate {
  func didSelectAdjuster() {
    if let id = Defaults.value(for: Defaults.UserID), let name = Defaults.value(for: Defaults.UserName) {
      self.baseController.pushViewController(claimsController(id, name: name), animated: true)
      return
    }
    self.baseController?.present(loginViewController(), animated: true, completion: nil)
  }
  
  func didSelectInsured() {
    self.baseController.pushViewController(dashboardController(), animated: true)
  }
}

// MARK: LoginViewDelegate
extension AppCoordinator: LoginViewDelegate {
  
  func signin(user: String, password: String, rememberMe: Bool) {
    DLOG("Username: \(user), Password: \(password)")
    Networking.send(AuthenticateUser(username: user, password: password)) { (result: Result<AuthenticateResult, Error>) in
      switch result {
      case .success(let result):
        switch result.result {
        case .success:
          DLOG(result.result.rawValue)
          if rememberMe {
            Defaults.save(result.userid, key: Defaults.UserID)
            Defaults.save("\(result.firstname) \(result.lastname)", key: Defaults.UserName)
          }
          UI {
            self.baseController?.presentedViewController?.dismiss(animated: true, completion: {
              self.baseController.pushViewController(self.claimsController(result.userid, name: "\(result.firstname) \(result.lastname)"), animated: true)
            })
          }
        case .failure:
          DLOG("Failed to Authenticate")
          self.displayError(.serverError)
        }
      case .failure(let error):
        DLOG("Error Communicating with Server: \(error)")
        self.displayError(.loginFail)
      }
    }
  }
  
  func emailValidationError() {
    displayError(.emailValidationError)
  }
  
  func passwordEmpty() {
    displayError(.emptyPassword)
  }
}

// MARK: ClaimsListDelegate
extension AppCoordinator: ClaimsListDelegate {
  func fetchError() {
    displayError(.errorFetchingLaims)
  }
  
  func pushToSelect() {
    if let userID = Defaults.value(for: Defaults.UserID) {
      self.baseController.pushViewController(searchController(userID), animated: true)
    }
  }
  
  func didSelectClaim(_ claimID: String) {
    DLOG("Received StreamID: \(claimID)")
    self.baseController.pushViewController(videoStreamController(claimID, claimID, streamURL: Configuration.streamURL), animated: true)
  }
  
  func errorRemovingClaim() {
    self.displayError(.errorRemovingClaim)
  }
  
  func pushToCamera(_ claimID: String) {
    self.baseController.pushViewController(cameraController(claimID), animated: true)
  }
  
  func pushToImages(_ claimID: String) {
    self.baseController.pushViewController(imageListController(claimID), animated: true)
  }
}

extension AppCoordinator: SearchControllerDelegate { }

// MARK: CameraDelegate
extension AppCoordinator: CameraViewControllerDelegate {
  func didCapturePhoto(_ imageData: Data, claimID: String) {
    UI {
      self.baseController.pushViewController(self.imagePreviewController(imageData, title: nil, notes: nil, claimID: claimID), animated: true)
    }
  }
}

// MARK: PreviewNotesDelegate
extension AppCoordinator: PreviewNotesDelegate {
  func submit(_ base64Image: String, _ title: String, _ notes: String, _ claimID: String) {
    Networking.send(SendImageRequest(claimID: claimID, base64Image: base64Image, photoID: "", title: title, caption: notes)) {
      (result: Result<SuccessFailureResult, Error>) in
      switch result {
      case .success(let result):
        switch result.result {
        case .success:
          DLOG("Success Uploading Image")
          UI { self.baseController.popViewController(animated: true) }
        case .failure:
          self.displayError(.failedToUploadImage)
        }
      case .failure:
        self.displayError(.failedToUploadImage)
      }
    }
  }
  
  func addNotes(_ callback: @escaping NotesCallback, _ existingNotes: String?) {
    self.baseController.pushViewController(self.notesController(existingNotes, callback: callback), animated: true)
  }
}

// MARK: ImageListDelegate
extension AppCoordinator: ImageListDelegate {
  func didSelectImage(_ details: PhotoDetail, claimID: String) {
    self.baseController.applyLoader()
    Networking.send(ImageRequest(details.image)) { (result: Result<Data, Error>) in
      switch result {
      case .success(let data):
        UI {
          let previewController = self.imagePreviewController(data, title: details.title, notes: details.caption, claimID: claimID)
          self.baseController.pushViewController(previewController, animated: true)
          self.baseController.removeLoader()
        }
      case .failure:
        UI {
          self.baseController.removeLoader()
          self.displayError(.failedToFetchImage)
        }
      }
    }
  }
}
