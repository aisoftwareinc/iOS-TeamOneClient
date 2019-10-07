//
//  EndStreamRequest.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 9/8/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation

struct EndStreamRequest: Request {
  
  let streamID: String
  
  init(_ streamID: String) {
    self.streamID = streamID
  }
  
  var type: RequestType {
    return .post
  }
  
  var url: String {
    return "http://demo.teamonecms.com/ws/media.asmx/EndVideoSession"
  }
  
  func build() -> URLRequest {
    var urlRequest = URLRequest(url: URL(string: url)!)
    let data = "StreamID=\(streamID)"
    let dataString = data.data(using: .utf8, allowLossyConversion: false)
    urlRequest.httpMethod = type.rawValue
    urlRequest.httpBody = dataString
    urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    urlRequest.setValue("\(dataString!.count)", forHTTPHeaderField: "content-length")
    return urlRequest
  }
}


struct PostStreamRequest: Request {
  
  let streamID: String
  let antMediaID: String
  
  init(_ streamID: String, _ antMediaID: String) {
    self.streamID = streamID
    self.antMediaID = antMediaID
  }
  
  var type: RequestType {
    return .post
  }
  
  var url: String {
    return "http://demo.teamonecms.com/ws/media.asmx/PostVideoStream"
  }
  
  func build() -> URLRequest {
    var urlRequest = URLRequest(url: URL(string: url)!)
    let data = "StreamID=\(streamID)&AntMediaStreamID=\(antMediaID)"
    let dataString = data.data(using: .utf8, allowLossyConversion: false)
    urlRequest.httpMethod = type.rawValue
    urlRequest.httpBody = dataString
    urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    urlRequest.setValue("\(dataString!.count)", forHTTPHeaderField: "content-length")
    return urlRequest
  }
}
