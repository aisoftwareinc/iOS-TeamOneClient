//
//  GenericInfoCell.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/11/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import UIKit

class GenericInfoCell: UITableViewCell {
  
  @IBOutlet weak var infoText: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.backgroundColor = Colors.background
    self.infoText.textColor = Colors.white
  }
  
  func configure(_ text: String) {
    self.infoText.text = text
  }
  
}
