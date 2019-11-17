//
//  DashBoardController.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 8/11/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import UIKit
import Asterism

protocol DashboardDelegate: class {
  func didEnterClaimsNumber(_ string: String)
  func noClaimNumberEntered()
  func onlyNumbers()
}

class DashBoardController: UIViewController {
  
  @IBOutlet weak var claimNumberField: PrimaryTextField!
  
  weak var delegate: DashboardDelegate?
  
  init(delegate: DashboardDelegate) {
    self.delegate = delegate
    super.init(nibName: nil, bundle: nil)
  }
  
  deinit {
    DLOG("Dashboard VC Deinit...")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpView()
    addKeyboardDismissTap()
  }
  
  
  @objc
  func dismissKeyboard() {
    UI { self.claimNumberField.resignFirstResponder() }
  }
  
  private func setUpView() {
    self.title = "Team One"
    self.view.backgroundColor = Colors.background
    claimNumberField.attributedPlaceholder = NSAttributedString(string: "Enter Claim ID", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
  }
  
  private func addKeyboardDismissTap() {
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(gesture)
  }
  
  @IBAction func submitClaim(_ sender: UIButton) {
    guard let claimID = claimNumberField.text, claimID != "" else {
      delegate?.noClaimNumberEntered()
      return
    }
    let characterSet = CharacterSet.decimalDigits.inverted
    
    guard (claimID.rangeOfCharacter(from: characterSet) == nil) else {
      delegate?.onlyNumbers()
      return
    }
    delegate?.didEnterClaimsNumber(claimID)
    self.claimNumberField.resignFirstResponder()
  }
}
