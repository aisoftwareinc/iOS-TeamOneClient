//
//  ScrapeResult.swift
//  WhiskeyTracker
//
//  Created by Peter Gosling on 8/2/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation

struct ScrapeResult: Decodable {
  let source: String
  let post: String
  let id: Int
  let timestamp: Int
}
