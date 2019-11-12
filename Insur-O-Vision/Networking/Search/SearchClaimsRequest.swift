//
//  SearchClaimsRequest.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/11/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation

struct SearchClaimsRequest: Request {
  let userID: String
  let searchTerm: String
  
  var methodType: RequestType {
    .post
  }
  
  var url: String {
    Configuration.apiEndpoint + "ws/media.asmx/SearchClaims"
  }
  
  var type: ContentType {
    let data = "UserID=\(userID)&SearchValue=\(searchTerm)"
    let dataString = data.data(using: .utf8, allowLossyConversion: false)
    return .urlencoded(dataString!)
  }
}
