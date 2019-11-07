//
//  ListClaimsResult.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/6/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation

struct ListClaimsResult: Decodable {
  let claims: [Claim]
}

struct Claim: Decodable {
  let claimid: String
  let streamid: String
  let claimnumber: String
  let insuredname: String
  let lossaddress: String
  let losscity: String
  let lossstate: String
  let losszip: String
}

