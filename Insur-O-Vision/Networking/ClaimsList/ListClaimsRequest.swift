//
//  ListClaimsRequest.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/6/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation

struct ListClaimsRequest: Request {
  
  let userID: String
  
  var type: RequestType {
    return .post
  }
  
  var url: String {
    return Configuration.apiEndpoint + "ws/media.asmx/ListClaims"
  }
  
  func build() -> URLRequest {
    var urlRequest = URLRequest(url: URL(string: url)!)
    let data = "UserID=\(userID)"
    let dataString = data.data(using: .utf8, allowLossyConversion: false)
    urlRequest.httpMethod = type.rawValue
    urlRequest.httpBody = dataString
    urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    urlRequest.setValue("\(dataString!.count)", forHTTPHeaderField: "content-length")
    return urlRequest
  }
}
