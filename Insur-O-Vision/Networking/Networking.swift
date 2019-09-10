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
  
  
  static func send<T: Request, ResultType: Decodable>(request: T, completion: (((Result<ResultType, Error>) -> Void)?) = nil) {
    let session = URLSession.init(configuration: .default)
    let dataTask = session.dataTask(with: request.build()) { (data, response, error) in
      DLOG("Network Response: Request - \(T.self) - Response \((response as! HTTPURLResponse).statusCode)")
      if let error = error {
        completion?(.failure(error))
        return
      }
      
      if let data = data {
        do {
          DLOG("JSON Response: Request - \(T.self) - \(String(data: data, encoding: .utf8) ?? "Unable to build String from Data result.")")
          let result = try JSONDecoder().decode(ResultType.self, from: data)
          completion?(.success(result))
        } catch {
          completion?(.failure(error))
        }
      }
    }
    dataTask.resume()
  }
}
