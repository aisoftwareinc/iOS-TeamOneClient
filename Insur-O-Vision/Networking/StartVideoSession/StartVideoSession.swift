import Foundation
import Asterism

struct StartVideoSession: Request {
  
  let streamID: String
  
  var methodType: RequestType {
    .post
  }
  
  var url: String {
    Configuration.apiEndpoint + "/StartVideoSession"
  }
  
  var type: ContentType {
    let dataString = "StreamID=\(streamID)"
    let data = dataString.data(using: .utf8, allowLossyConversion: false)
    return .urlencoded(data!)
  }
  
  var headers: [String : String]?
}
