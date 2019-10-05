//
//  SendImageRequest.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 8/28/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation

struct SendImageRequest: Request {
  private let streamID: String
  private let base64Image: String
  
  var type: RequestType {
    return .post
  }
  
  var url: String {
    return Configuration.apiEndpoint + "ws/media.asmx/PostPhoto"
  }
  
  func build() -> URLRequest {
    var urlRequest = URLRequest(url: URL(string: url)!)
    let data = "Photo=\(base64Image)&StreamID=\(streamID)"
    let dataString = data.data(using: .utf8, allowLossyConversion: false)
    urlRequest.httpMethod = type.rawValue
    urlRequest.httpBody = dataString
    urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    urlRequest.setValue("\(dataString!.count)", forHTTPHeaderField: "content-length")
    return urlRequest
  }
  
  init(_ stream: String, base64Image: String) {
    self.streamID = stream
    self.base64Image = base64Image
  }
}

extension String {
  public func stringByAddingPercentEncodingForFormData(plusForSpace: Bool = false) -> String? {
    let unreserved = "*-._"
    let allowed = NSMutableCharacterSet.alphanumeric()
    allowed.addCharacters(in: unreserved)
    
    if plusForSpace {
      allowed.addCharacters(in: " ")
    }
    
    var encoded = addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    if plusForSpace {
      encoded = encoded?.replacingOccurrences(of: " ", with: "+")
    }
    return encoded
  }
}
