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
  @IBOutlet weak var cameraButton: UIButton!
  @IBOutlet weak var allImageButton: UIButton!
  @IBOutlet weak var videoButton: UIButton!
  
  var cameraAction: (() -> Void)?
  var allImagesAction: (() -> Void)?
  var videoAction: (() -> Void)?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.selectionStyle = .none
    self.backgroundColor = Colors.background
    self.insuredName.textColor = Colors.white
    self.address.textColor = Colors.white
    self.claimReferenceNumbers.textColor = Colors.primary
    self.cameraButton.tintColor = .white
    self.allImageButton.tintColor = .white
    self.videoButton.tintColor = .white
  }
  
  func configure(_ claim: Claim) {
    self.insuredName.text = claim.insuredname
    self.address.text = "\(claim.lossaddress) \(claim.losscity) \(claim.lossstate) \(claim.losszip)"
    self.claimReferenceNumbers.text = "Claim #: \(claim.claimnumber) - TeamOne #: \(claim.teamonenumber)"
  }
  
  @IBAction func cameraAction(_ sender: UIButton) {
    cameraAction?()
  }
  
  @IBAction func allImagesAction(_ sender: UIButton) {
    allImagesAction?()
  }
  
  @IBAction func videoAction(_ sender: UIButton) {
    videoAction?()
  }
}
