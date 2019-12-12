//
//  ImageRequest.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 12/10/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation
import Asterism

struct ImageRequest: Request {
  
  var url: String
  
  init(_ url: String) {
    self.url = url
  }
  
  var methodType: RequestType {
    .get
  }

  var type: ContentType {
    .none
  }
  
  var headers: [String : String]?

}
