//
//  Colors.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 8/11/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

struct Colors {
  static let background = UIColor(hex: "24272b")
  static let secondaryBackground = UIColor(hex: "4a525a")
  static let primary = UIColor.orange //UIColor(hex: "1537a5")
  static let secondary = UIColor(hex: "3e78b2")
  static let text = UIColor(hex: "07070a")
  static let white = UIColor.white
}

extension UIColor {
  convenience init(hex: String, alpha: CGFloat? = 1.0) {
    func intFromHexString(hexStr: String) -> UInt32 {
      var hexInt: UInt32 = 0
      // Create scanner
      let scanner: Scanner = Scanner(string: hexStr)
      // Tell scanner to skip the # character
      scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
      // Scan hex value
      scanner.scanHexInt32(&hexInt)
      return hexInt
    }
    // Convert hex string to an integer
    let hexint = Int(intFromHexString(hexStr: hex))
    let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
    let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
    let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
    let alpha = alpha!
    
    // Create color object, specifying alpha as well
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}
