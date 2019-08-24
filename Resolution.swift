//
//  Resolution.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 8/23/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation

protocol Resolution {
  var height: Int { get }
  var width: Int { get }
}

struct HighResolution: Resolution {
  var height: Int = 1080
  var width: Int = 1920
}

struct Default: Resolution {
  var height: Int = 720
  var width: Int = 1280
}

struct LowResolution: Resolution {
  var height: Int = 480
  var width: Int = 720
}
