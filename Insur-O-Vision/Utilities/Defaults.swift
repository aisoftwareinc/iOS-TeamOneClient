//
//  Defaults.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/8/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation

struct Defaults {
  static let UserID: String = "UserID"
  static func save(_ value: String, key: String) {
    UserDefaults.standard.set(value, forKey: key)
  }
  
  static func value(for key: String) -> String? {
    return UserDefaults.standard.value(forKey: key) as? String ?? nil
  }
  
  static func remove(_ key: String) {
    UserDefaults.standard.removeObject(forKey: key)
  }
}
