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
  
  enum ErrorState: String {
    case loginFail = "Login Error: Please try login and password again."
    case genericError = "An error occured. Try Again."
    case serverError = "An error occured communicating with server."
    case emailValidationError = "Only valid email addresses can be used."
    case errorRemovingClaim = "An error occured removing claim. Try again."
    case emptyPassword = "Please enter valid password."
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
  
  private func videoStreamController(_ streamID: String) -> VideoStreamController {
    return VideoStreamController(VideoStreamHandler(Configuration.streamURL, id: streamID), streamID)
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
    return SearchController(userID)
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
  
  func signin(user: String, password: String) {
    DLOG("Username: \(user), Password: \(password)")
    Networking.send(AuthenticateUser(username: user, password: password)) { (result: Result<AuthenticateResult, Error>) in
      switch result {
      case .success(let result):
        DLOG(result.result.rawValue)
        Defaults.save(result.userid, key: Defaults.UserID)
        Defaults.save("\(result.firstname) \(result.lastname)", key: Defaults.UserName)
        switch result.result {
        case .success:
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
  func pushToSelect() {
    if let userID = Defaults.value(for: Defaults.UserID) {
      self.baseController.pushViewController(searchController(userID), animated: true)
    }
  }
  
  func didSelectClaim(_ streamID: String) {
    DLOG("Received StreamID: \(streamID)")
    self.baseController.pushViewController(videoStreamController(streamID), animated: true)
  }
  
  func errorRemovingClaim() {
    self.displayError(.errorRemovingClaim)
  }
}
