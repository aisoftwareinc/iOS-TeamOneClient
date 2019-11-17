//
//  SuccessFailureResult.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/6/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation
import Asterism

enum SuccessResult: String, Decodable {
  case success = "Success"
  case failure = "Failure"
}

struct SuccessFailureResult: Decodable {
  let result: SuccessResult
}
