//
//  String+.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/11/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation

extension String {
  func isValidEmail() -> Bool {
      let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
      let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
      return emailPred.evaluate(with: self)
  }
  
  public func stringByAddingPercentEncodingForFormData(plusForSpace: Bool = false) -> String? {
    let unreserved = "*-._"
    let allowed = NSMutableCharacterSet.alphanumeric()
    allowed.addCharacters(in: unreserved)
    
    if plusForSpace {
      allowed.addCharacters(in: " ")
    }
    
    var encoded = addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    if plusForSpace {
      encoded = encoded?.replacingOccurrences(of: " ", with: "+")
    }
    return encoded
  }
}
