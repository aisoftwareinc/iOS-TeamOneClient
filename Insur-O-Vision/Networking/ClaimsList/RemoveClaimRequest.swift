import Foundation


struct RemoveClaimRequest: Request {
  
  let claimID: String
  
  var methodType: RequestType {
    return .post
  }
  
  var url: String {
    return Configuration.apiEndpoint + "ws/media.asmx/RemoveClaim"
  }
  
  var type: ContentType {
    let data = "ClaimID=\(claimID)"
    let dataString = data.data(using: .utf8, allowLossyConversion: false)
    return .urlencoded(dataString!)
  }
}
