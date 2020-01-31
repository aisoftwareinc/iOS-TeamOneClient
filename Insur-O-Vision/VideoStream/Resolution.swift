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
  var bitrate: Int { get }
}

struct HighResolution: Resolution {
  var height: Int = 1080
  var width: Int = 1920
  var bitrate: Int = 1500
}

struct DefaultResolution: Resolution {
  var height: Int = 720
  var width: Int = 1280
  var bitrate: Int = 500
}

struct LowResolution: Resolution {
  var height: Int = 480
  var width: Int = 720
  var bitrate: Int = 250
}
