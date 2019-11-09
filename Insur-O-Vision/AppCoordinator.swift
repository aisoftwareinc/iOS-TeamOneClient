//
//  AppCoordinator.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 8/9/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation
import UIKit

class AppCoordinator {

  private let locationManager = LocationManager()
  var baseController: UINavigationController!
  
  func start() -> UIViewController {
    let initialController = Configuration.didSeeEULA ? appModeSelectionController() : eulaController()
    baseController = UINavigationController(rootViewController: initialController)
    locationManager.start()
    return baseController
  }
  
  private func dashboardController() -> DashBoardController {
    return DashBoardController(delegate: self)
  }
  
  private func eulaController() -> EULAController {
    return EULAController(delegate: self)
  }
  
  private func videoStreamController(_ streamID: String) -> VideoStreamController {
    let streamHandler = VideoStreamHandler(Configuration.streamURL, id: streamID)
    return VideoStreamController(streamHandler, streamID)
  }
  
  private func appModeSelectionController() -> ModeSelectionController {
    return ModeSelectionController(self)
  }
  
  private func loginViewController() -> LoginViewController {
    return LoginViewController(self)
  }
  
  private func claimsController(_ id: String) -> ClaimsListController {
    return ClaimsListController(id, self)
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
  
  func didEnterClaimsNumber(_ string: String) {
    self.baseController.pushViewController(videoStreamController(string), animated: true)
    locationManager.sendLocation(string)
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
    if let id = Defaults.value(for: Defaults.UserID) {
      self.baseController.pushViewController(claimsController(id), animated: true)
      return
    }
    self.baseController?.present(loginViewController(), animated: true, completion: nil)
  }
  
  func didSelectInsured() {
    self.baseController.pushViewController(dashboardController(), animated: true)
  }
}

extension AppCoordinator: LoginViewDelegate {
  func signin(user: String, password: String) {
    DLOG("Username: \(user), Password: \(password)")
    Networking.send(AuthenticateUser(username: user, password: password)) { (result: Result<AuthenticateResult, Error>) in
      switch result {
      case .success(let result):
        DLOG(result.result.rawValue)
        Defaults.save(result.userid, key: Defaults.UserID)
        switch result.result {
        case .success:
          UI {
            self.baseController?.presentedViewController?.dismiss(animated: true, completion: {
              self.baseController.pushViewController(self.claimsController(result.userid), animated: true)
            })
          }
        case .failure:
          DLOG("Failed to Authenticate")
        }
      case .failure(let error):
        DLOG("Error Communicating with Server: \(error)")
      }
    }
  }
  
  func validationError() {
    DLOG("Validation Error!")
  }
}


extension AppCoordinator: ClaimsListDelegate {
  func didSelectClaim(_ streamID: String) {
    DLOG("Received StreamID: \(streamID)")
    self.baseController.pushViewController(videoStreamController(streamID), animated: true)
  }
  
  
}
