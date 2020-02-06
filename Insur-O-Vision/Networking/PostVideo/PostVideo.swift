import Foundation
import Asterism


struct PostVideo: Request {
  var headers: [String : String]?
  
  let claimID: String
  let streamID: String
  
  var methodType: RequestType {
    .post
  }
  
  var url: String {
    Configuration.apiEndpoint + "/PostVideo"
  }
  
  var type: ContentType {
    let dataString = "StreamID=\(streamID)&ClaimID=\(claimID)"
    let data = dataString.data(using: .utf8, allowLossyConversion: false)
    return .urlencoded(data!)
  }
}
