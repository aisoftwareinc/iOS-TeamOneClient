import Asterism
import Foundation

struct BuildPhotoBook: Request {
  
  let claimID: String
  
  var methodType: RequestType {
    .post
  }
  
  var url: String {
    Configuration.apiEndpoint + "/BuildPhotoBook"
  }
  
  var type: ContentType {
    let dataString = "ClaimID=\(claimID)"
    let data = dataString.data(using: .utf8, allowLossyConversion: false)
    return .urlencoded(data!)
  }
  
  var headers: [String : String]?
  
  
}
