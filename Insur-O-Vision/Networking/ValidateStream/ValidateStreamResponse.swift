//
//  ValidateStreamResponse.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/18/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation

struct ValidateStreamResponse: Decodable {
  let result: SuccessResult
  let streamtype: String
  let streamurl: String
  let claimid: String
}

enum StreamType: String, Decodable {
  case live = "Stream"
  case record = "Stream-Record"
}
