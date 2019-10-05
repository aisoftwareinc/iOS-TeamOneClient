//
//  LocationRequest.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 9/8/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

struct PostUserInformation: Request {
  
  let location: CLLocation
  let streamID: String
  let modelName: String
  let iOSVersion: String
  let batteryLevel: String
  
  init(_ location: CLLocation, streamID: String, modelName: String, iOSVersion: String) {
    self.location = location
    self.streamID = streamID
    self.modelName = modelName
    self.iOSVersion = iOSVersion
    UIDevice.current.isBatteryMonitoringEnabled = true
    batteryLevel = String(UIDevice.current.batteryLevel)
  }
  
  var type: RequestType {
    return .post
  }
  
  var url: String {
    return Configuration.apiEndpoint + "ws/media.asmx/PostUserInformation"
  }
  
  func build() -> URLRequest {
    var urlRequest = URLRequest(url: URL(string: url)!)
    let data = "Latitude=\(location.coordinate.latitude)&Longitude=\(location.coordinate.longitude)&StreamID=\(streamID)&ModelName=\(self.modelName)&ModelNumber=iPhone&SoftwareVersion=\(self.iOSVersion)&Carrier=NA&BatteryPercent=\(batteryLevel)"
    let dataString = data.data(using: .utf8, allowLossyConversion: false)
    urlRequest.httpMethod = type.rawValue
    urlRequest.httpBody = dataString
    urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    urlRequest.setValue("\(dataString!.count)", forHTTPHeaderField: "content-length")
    return urlRequest
  }
}
