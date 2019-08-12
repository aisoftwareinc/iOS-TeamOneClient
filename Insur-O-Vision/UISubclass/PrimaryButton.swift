//
//  PrimaryButton.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 8/11/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation
import UIKit

class PrimaryButton: UIButton {
  init() {
    super.init(frame: .zero)
    self.backgroundColor = Colors.primary
    self.setTitleColor(Colors.text, for: .normal)
    self.layer.cornerRadius = 3.0
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.backgroundColor = Colors.primary
    self.setTitleColor(UIColor.white, for: .normal)
    self.layer.cornerRadius = 3.0
  }
}
