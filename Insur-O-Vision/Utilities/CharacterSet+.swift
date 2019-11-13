//
//  CharacterSet+.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/13/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation

extension CharacterSet {
  static let urlImageEncoded: CharacterSet = {
    let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
    let subDelimitersToEncode = "!$&'()*+,;="
    var allowed = CharacterSet.urlQueryAllowed
    allowed.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)
    return allowed
  }()
}
