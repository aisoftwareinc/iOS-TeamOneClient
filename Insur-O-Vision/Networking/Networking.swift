//
//  Networking.swift
//  WhiskeyTracker
//
//  Created by Peter Gosling on 12/17/18.
//  Copyright © 2018 Peter Gosling. All rights reserved.
//

import Foundation

struct Networking {
  
  enum NetworkError: Error {
    case success
    case noInternet
    case noResults
  }
  
  static func send<T: Request, ResultType: Decodable>(_ request: T, _ completion: @escaping ((Result<ResultType, Error>) -> Void)) {
    let session = URLSession.init(configuration: .default)
    let dataTask = session.dataTask(with: request.build()) { (data, response, error) in
      
      if let error = error {
        DLOG("Network Response: Request - \(T.self) - Error: \(error.localizedDescription)")
        completion(.failure(error))
        return
      }
      
      DLOG("Network Response: Request - \(T.self) - Response \((response as? HTTPURLResponse)?.statusCode ?? -1) - URL \(request.url)")
      
      if let data = data {
        do {
          DLOG("JSON Response: \(T.self) - URL: \(request.url)\n\(data.prettyJSON() ?? "Unable to build String from Data result.")")
          let result = try JSONDecoder().decode(ResultType.self, from: data)
          completion(.success(result))
        } catch {
          completion(.failure(error))
        }
      }
    }
    dataTask.resume()
  }
}

enum SuccessResult: String, Decodable {
  case success = "Success"
  case failure = "Failure"
}

public extension Data {
  
  /// Convert self to JSON String.
  /// - Returns: Returns the JSON as String or empty string if error while parsing.
  func prettyJSON() -> String? {
    do {
      let jsonObject = try JSONSerialization.jsonObject(with: self, options: [])
      let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
      guard let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) else {
        return "Error converting string to pretty JSON"
      }
      return jsonString
    } catch let parseError {
      return "JSON serialization error: \(parseError)"
    }
  }
}
