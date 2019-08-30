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

  var baseController: UINavigationController!
  
  func start() -> UIViewController {
    let initialController = Configuration.didSeeEULA ? dashboardController() : eulaController()
    baseController = UINavigationController(rootViewController: initialController)
    return baseController
  }
  
  private func dashboardController() -> DashBoardController {
    return DashBoardController(delegate: self)
  }
  
  private func eulaController() -> EULAController {
    return EULAController(delegate: self)
  }
  
  private func videoStreamController(_ streamID: String) -> VideoStreamController {
    let streamHandler = StreamHandler("rtmp://ec2-52-86-161-206.compute-1.amazonaws.com/LiveApp/", id: streamID)
    return VideoStreamController(streamHandler)
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
  func didEnterClaimsNumber(_ string: String) {
    self.baseController.pushViewController(videoStreamController(string), animated: true)
  }
  
  func noClaimNumberEntered() {
    print("Handle No Claim Number")
  }
}
