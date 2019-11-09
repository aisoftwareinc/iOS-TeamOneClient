//
//  Request.swift
//  WhiskeyTracker
//
//  Created by Peter Gosling on 8/2/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation

enum RequestType: String {
  case get = "GET"
  case post = "POST"
}

enum ContentType {
  case json(Data)
  case urlencoded(Data)
  case multipart(Data)
}

protocol Request {
  var methodType: RequestType { get }
  var url: String { get }
  var type: ContentType { get }
  func build() -> URLRequest
}

extension Request {
  func build() -> URLRequest {
    var urlRequest = URLRequest(url: URL(string: url)!)
    switch type {
    case .json(let data):
      urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
      urlRequest.setValue("\(data.count)", forHTTPHeaderField: "content-length")
      urlRequest.httpBody = data
    case .urlencoded(let data):
      urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
      urlRequest.setValue("\(data.count)", forHTTPHeaderField: "content-length")
      urlRequest.httpBody = data
    case .multipart(let data):
      urlRequest.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
      urlRequest.setValue("\(data.count)", forHTTPHeaderField: "content-length")
      urlRequest.httpBody = data
    }
    urlRequest.httpMethod = methodType.rawValue
    return urlRequest
  }
}
