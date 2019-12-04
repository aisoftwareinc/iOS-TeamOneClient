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
  @IBOutlet weak var claimReferenceNumbers: UILabel!
  
  var cameraAction: (() -> Void)?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.backgroundColor = Colors.background
    self.insuredName.textColor = Colors.white
    self.address.textColor = Colors.white
    self.claimReferenceNumbers.textColor = Colors.primary
  }
  
  func configure(_ claim: Claim) {
    self.insuredName.text = claim.insuredname
    self.address.text = "\(claim.lossaddress) \(claim.losscity) \(claim.lossstate) \(claim.losszip)"
    self.claimReferenceNumbers.text = "Claim #: \(claim.claimnumber) - TeamOne #: \(claim.teamonenumber)"
  }
  
  @IBAction func cameraAction(_ sender: UIButton) {
    cameraAction?()
  }
}
