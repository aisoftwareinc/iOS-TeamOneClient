//
//  AuthenticateUser.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/6/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation
import Asterism

struct AuthenticateUser: Request {
  
  let username: String
  let password: String
  
  var methodType: RequestType {
    .post
  }
  
  var url: String {
    return Configuration.apiEndpoint + "ws/media.asmx/AuthenticateUser"
  }
  
  var type: ContentType {
    let data = "Username=\(username)&Password=\(password)"
    let dataString = data.data(using: .utf8, allowLossyConversion: false)
    return .urlencoded(dataString!)
  }
}
