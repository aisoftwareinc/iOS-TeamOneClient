//
//  SendImageRequest.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 8/28/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation
import Asterism

struct SendImageRequest: Request {
  let claimID: String
  let base64Image: String
  let photoID: String
  let title: String
  let caption: String
  
  var methodType: RequestType {
    return .post
  }
  
  var url: String {
    return Configuration.apiEndpoint + "/PostPhoto"
  }
  
  var type: ContentType {
    let data = "Photo=\(base64Image)&PhotoID=1&Title=\(title)&Caption=\(caption)&ClaimID=\(claimID)"
    let dataString = data.data(using: .utf8, allowLossyConversion: false)
    return .urlencoded(dataString!)
  }
  var headers: [String : String]?
}
