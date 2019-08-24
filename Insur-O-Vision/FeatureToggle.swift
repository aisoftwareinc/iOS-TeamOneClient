//
//  FeatureToggle.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 8/17/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation

enum Feature {
  
  static private(set) var availableFeatures: AvailableFeatures?
  
  func set(_ features: AvailableFeatures) {
    Feature.availableFeatures = features
  }
  
  case screenCapture
  case locationCapture
  case flash
  case zoom
}

struct AvailableFeatures: Codable {
  let screenCapture: Bool
  let locationCapture: Bool
  let flash: Bool
  let zoom: Bool
}
