//
//  LocationManager.swift
//  LocationTracker
//
//  Created by Peter Gosling on 7/26/17.
//  Copyright © 2017 Peter Gosling. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class LocationManager: NSObject {
  
  var locationManager: CLLocationManager!
  var currentLocation: CLLocation?
  var timeInterval: Double = 10000.0
  var isUpdating: Bool = false
  var didSendInitial: Bool = false
  
  private var timer : Timer!
  
  override init() {
    super.init()
    self.locationManager = CLLocationManager()
    self.locationManager.requestWhenInUseAuthorization()
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager.pausesLocationUpdatesAutomatically = false
  }
  
  func start() {
    if !self.isUpdating {
      self.locationManager.startUpdatingLocation()
      self.isUpdating = true
    }
  }
  
  func sendLocation(_ streamID: String) {
    guard let currentLocation = self.currentLocation else {
      return
    }
    
    print("Sending Location: \(currentLocation)")
    let locationRequest = PostUserInformation(currentLocation, streamID: streamID, modelName: UIDevice.current.model, iOSVersion: UIDevice.current.systemVersion)
    Networking.send(locationRequest) { (result: Result<NoResponse, Error>) in
      
    }
    //        let locationRequest = Requests.reportLocationPostRequest(String(currentLocation.coordinate.latitude), String(currentLocation.coordinate.longitude))
    //        print("Sending location: \(String(currentLocation.coordinate.latitude), String(currentLocation.coordinate.longitude))")
    //        Networking.send(locationRequest, completion: { (result: Result<Success>) in
    //            switch result {
    //            case .success(let response):
    //                print(response)
    //            case .failure:
    //                print("Failure")
    //            }
    //        })
  }
  
  func stop() {
    if self.isUpdating {
      self.locationManager.stopUpdatingLocation()
      self.isUpdating = false
      self.didSendInitial = false
      self.timeInterval = 10000.0
    }
  }
}

extension LocationManager: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("Received new location \(locations[0].coordinate)")
    self.currentLocation = locations[0]
    self.stop()
  }
}

