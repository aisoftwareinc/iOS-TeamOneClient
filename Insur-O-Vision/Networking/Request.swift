//
//  Request.swift
//  WhiskeyTracker
//
//  Created by Peter Gosling on 8/2/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation

enum RequestType: String {
  case get = "GET"
  case post = "POST"
}

protocol Request {
  var type: RequestType { get }
  var url: String { get }
  func build() -> URLRequest
}
