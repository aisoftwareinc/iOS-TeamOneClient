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
    let initialController = Configuration.didSeeEULA ? dashboardController() : eulaController()
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
    let streamHandler = StreamHandler(Configuration.streamURL, id: streamID)
    return VideoStreamController(streamHandler, streamID)
  }
}

// MARK: EULADelegate
extension AppCoordinator: EULADelegate {
  func didAccept() {
    Configuration.save(true)
    self.baseController.pushViewController(dashboardController(), animated: true)
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
