//
//  ScrapeRequest.swift
//  WhiskeyTracker
//
//  Created by Peter Gosling on 8/2/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation

struct ScrapeRequest: Request {
  var type: RequestType { return .get }
  var url: String { return "URL" + "/fetchResults" }
  
  func build() -> URLRequest {
    var request = URLRequest.init(url: URL.init(string: url)!)
    request.httpMethod = type.rawValue
    return request
  }
}
