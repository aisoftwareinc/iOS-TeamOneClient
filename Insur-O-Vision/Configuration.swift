//
//  Configuration.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 8/11/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation

struct Configuration {
  
  private static let eula = "EULA"
  
  static func save(_ didAgree: Bool) {
    UserDefaults.standard.set(didAgree, forKey: self.eula)
  }
  
  static var didSeeEULA: Bool {
    return UserDefaults.standard.value(forKey: self.eula) as? Bool ?? false
  }
}