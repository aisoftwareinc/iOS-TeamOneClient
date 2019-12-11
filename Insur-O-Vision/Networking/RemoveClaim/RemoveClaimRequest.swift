import Foundation
import Asterism


struct RemoveClaimRequest: Request {
  
  let claimID: String
  
  var methodType: RequestType {
    return .post
  }
  
  var url: String {
    return Configuration.apiEndpoint + "/RemoveClaim"
  }
  
  var type: ContentType {
    let data = "ClaimID=\(claimID)"
    let dataString = data.data(using: .utf8, allowLossyConversion: false)
    return .urlencoded(dataString!)
  }
  
  var headers: [String : String]?
}
