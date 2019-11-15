//
//  PrimaryTextField.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 8/11/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation
import UIKit

class PrimaryTextField: UITextField {
  
  init() {
    super.init(frame: .zero)
    self.layer.cornerRadius = 4.0
    self.layer.borderColor = Colors.secondaryBackground.cgColor
    self.layer.borderWidth = 1.0
    self.backgroundColor = UIColor.clear
    self.textColor = UIColor.white
    self.tintColor = .white
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.layer.cornerRadius = 4.0
    self.layer.borderColor = Colors.secondaryBackground.cgColor
    self.backgroundColor = UIColor.clear
    self.layer.borderWidth = 1.0
    self.textColor = UIColor.white
    let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 20))
    self.tintColor = .white
    leftView = paddingView
    leftViewMode = .always
  }
}
