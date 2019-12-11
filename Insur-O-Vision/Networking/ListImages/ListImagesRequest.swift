//
//  ListImagesRequest.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 12/10/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation
import Asterism

struct ListImagesRequest: Request {
  let claimID: String
  
  var methodType: RequestType {
    .post
  }
  
  var url: String {
    Configuration.apiEndpoint + "/ListPhotos"
  }
  
  var type: ContentType {
    let dataString = "ClaimID=\(claimID)"
    let data = dataString.data(using: .utf8, allowLossyConversion: false)
    return .urlencoded(data)
  }
  
  var headers: [String : String]?
}
