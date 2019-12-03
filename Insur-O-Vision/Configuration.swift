import Foundation

struct Configuration {
  
  private static let eula = "EULA"
  
  static func save(_ didAgree: Bool) {
    UserDefaults.standard.set(didAgree, forKey: self.eula)
  }
  
  static var didSeeEULA: Bool {
    return UserDefaults.standard.value(forKey: self.eula) as? Bool ?? false
  }
  
  static var streamURL: String {
    return "rtmp://www.teamonemediaserver.com/LiveApp/"
  }
  
  static var apiEndpoint: String {
    return "http://demo.teamonecms.com/"
  }
}
