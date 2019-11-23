//
//  GenericHeaderView.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/22/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import UIKit

class GenericHeaderView: UITableViewHeaderFooterView {
  @IBOutlet weak var background: UIView!
  @IBOutlet weak var headerLabel: UILabel!
  
  override func awakeFromNib() {
    self.background.backgroundColor = Colors.secondaryBackground
    headerLabel.textColor = Colors.white
  }
}
