//
//  ValidateStreamRequest.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/18/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation
import Asterism

struct ValidateStreamRequest: Request {
  let latitude: String
  let longitude: String
  let streamID: String
  
  var methodType: RequestType {
    return .post
  }
  
  var url: String {
    Configuration.apiEndpoint + "ws/media.asmx/ValidateStreamID"
  }
  
  var type: ContentType {
    let dataString = "StreamID=\(streamID)&Latitude=\(latitude)&Longitude=\(longitude)"
    let data = dataString.data(using: .utf8, allowLossyConversion: false)
    return .urlencoded(data!)
  }
}
