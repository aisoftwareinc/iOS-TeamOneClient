//
//  AuthenticateUser.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/6/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation

struct AuthenticateUser: Request {
  
  let username: String
  let password: String
  
  var type: RequestType {
    .post
  }
  
  var url: String {
    return Configuration.apiEndpoint + "ws/media.asmx/AuthenticateUser"
  }
  
  func build() -> URLRequest {
    var urlRequest = URLRequest(url: URL(string: url)!)
    let data = "Username=\(username)&Password=\(password)"
    let dataString = data.data(using: .utf8, allowLossyConversion: false)
    urlRequest.httpMethod = type.rawValue
    urlRequest.httpBody = dataString
    urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    urlRequest.setValue("\(dataString!.count)", forHTTPHeaderField: "content-length")
    return urlRequest
  }
}
