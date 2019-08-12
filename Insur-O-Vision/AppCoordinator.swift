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
  
  var streamHandler: StreamHandler!
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
  
  private func videoStreamController(_ streamingHandler: StreamHandler) -> VideoStreamController {
    return VideoStreamController(streamingHandler)
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
    streamHandler = StreamHandler("rtmp://ec2-52-15-121-242.us-east-2.compute.amazonaws.com/LiveApp/", id: string)
    self.baseController.pushViewController(videoStreamController(streamHandler), animated: true)
  }
  
  func noClaimNumberEntered() {
    print("Handle No Claim Number")
  }
}
