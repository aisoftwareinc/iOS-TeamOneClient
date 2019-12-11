//
//  ValidateStreamRequest.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/18/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation
import Asterism
import UIKit

struct ValidateStreamRequest: Request {
  let latitude: String
  let longitude: String
  let streamID: String
  let modelName: String
  let modelNumber: String
  let softwareVersion: String
  let carrier: String
  
  var methodType: RequestType {
    return .post
  }
  
  var url: String {
    Configuration.apiEndpoint + "/ValidateStreamID"
  }
  
  var battery: String {
    UIDevice.current.isBatteryMonitoringEnabled = true
    let batteryLevel = String(UIDevice.current.batteryLevel)
    return batteryLevel
  }
  
  var type: ContentType {
    let dataString = "StreamID=\(streamID)&Latitude=\(latitude)&Longitude=\(longitude)&ModelName=\(modelName)&ModelNumber=\(modelNumber)&SoftwareVersion=\(softwareVersion)&Carrier=\(carrier)&BatteryPercent=\(battery)"
    let data = dataString.data(using: .utf8, allowLossyConversion: false)
    return .urlencoded(data!)
  }
  
  var headers: [String : String]?
}
