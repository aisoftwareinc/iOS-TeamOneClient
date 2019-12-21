import Foundation
import CoreLocation
import UIKit
import Asterism
import UserNotifications

class LocationManager: NSObject {
  
  var locationManager: CLLocationManager!
  var currentLocation: CLLocation?
  var timeInterval: Double = 10000.0
  var isUpdating: Bool = false
  var didSendInitial: Bool = false
  
  private var timer : Timer!
  var pushToSettings: (() -> Void)?
  
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
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .authorizedAlways:
      DLOG("Accepted Location Services")
    case .authorizedWhenInUse:
      DLOG("Accepted Location Services")
    case .notDetermined:
      DLOG("Location Services not determined")
    case .restricted:
      DLOG("Restricted Location")
    case .denied:
      pushToSettings?()
    @unknown default:
      break
    }
  }
}

