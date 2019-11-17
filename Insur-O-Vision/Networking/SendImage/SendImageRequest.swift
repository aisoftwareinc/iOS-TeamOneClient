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
  private let streamID: String
  private let base64Image: String
  
  var methodType: RequestType {
    return .post
  }
  
  var url: String {
    return Configuration.apiEndpoint + "ws/media.asmx/PostPhoto"
  }
  
  var type: ContentType {
    let data = "Photo=\(base64Image)&StreamID=\(streamID)"
    let dataString = data.data(using: .utf8, allowLossyConversion: false)
    return .urlencoded(dataString!)
  }
  
  init(_ stream: String, base64Image: String) {
    self.streamID = stream
    self.base64Image = base64Image
  }
}
