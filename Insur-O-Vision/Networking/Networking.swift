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
  
  static func sendToken(_ token: String) {
    let url = URL(string: "https://whiskeybotnet.herokuapp.com/save?token=\(token)&os=iOS")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    let session = URLSession.shared
    session.dataTask(with: request).resume()
  }
  
  static func send<T: Request, ResultType: Decodable>(request: T, completion: (((Result<ResultType, Error>) -> Void)?) = nil) {
    let session = URLSession.init(configuration: .default)
    let dataTask = session.dataTask(with: request.build()) { (data, response, error) in
      
      if let error = error {
        completion?(.failure(error))
        return
      }
      
      if let data = data {
        do {
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
