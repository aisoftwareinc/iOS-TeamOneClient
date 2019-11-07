//
//  AuthenticateResult.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/6/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation

struct AuthenticateResult: Decodable {
  let result: SuccessResult
  let userid: String
  let firstname: String
  let lastname: String
}
