//
//  RegisterPush.swift
//  WhiskeyTracker
//
//  Created by Peter Gosling on 8/4/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation

struct RegisterPush: Request {
  var type: ContentType {
    return .json(Data())
  }
  
  private let token: String
  var methodType: RequestType {
    return .post
  }
  
  var url: String {
    return "Need URL"
  }
  
  init(_ token: String) {
    self.token = token
  }
  
  func build() -> URLRequest {
    var request = URLRequest.init(url: URL(string: url)!)
    request.httpMethod = methodType.rawValue
    return request
  }
  
  
}
