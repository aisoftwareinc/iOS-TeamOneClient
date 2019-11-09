//
//  ClaimsCell.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/6/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import UIKit

class ClaimsCell: UITableViewCell {
  
  @IBOutlet weak var insuredName: UILabel!
  @IBOutlet weak var address: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.backgroundColor = Colors.background
    self.insuredName.textColor = Colors.white
    self.address.textColor = Colors.white
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func configure(_ claim: Claim) {
    self.insuredName.text = claim.insuredname
    self.address.text = "\(claim.lossaddress) \(claim.losscity) \(claim.lossstate) \(claim.losszip)"
  }
}
