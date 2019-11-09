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
  
  var methodType: RequestType {
    return .post
  }
  
  var url: String {
    return Configuration.apiEndpoint + "ws/media.asmx/ListClaims"
  }
  
  var type: ContentType {
    let data = "UserID=\(userID)"
    let dataString = data.data(using: .utf8, allowLossyConversion: false)
    return .urlencoded(dataString!)
  }
}
