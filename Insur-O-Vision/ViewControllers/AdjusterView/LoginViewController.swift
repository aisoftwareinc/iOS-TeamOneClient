//
//  LoginViewController.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/5/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import UIKit

protocol LoginViewDelegate: class {
  func signin(user: String, password: String)
  func emailValidationError()
  func passwordEmpty()
}

class LoginViewController: UIViewController {
  
  @IBOutlet weak var signinLabel: UILabel!
  @IBOutlet weak var usernameField: PrimaryTextField!
  @IBOutlet weak var passworldField: PrimaryTextField!
  @IBOutlet weak var signinButton: PrimaryButton!
  
  weak var delegate: LoginViewDelegate?
  
  init(_ delegate: LoginViewDelegate) {
    self.delegate = delegate
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.modalPresentationStyle = .formSheet
    self.signinLabel.textColor = Colors.white
    self.view.backgroundColor = Colors.background
    usernameField.attributedPlaceholder = NSAttributedString(string: "Email Address", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    passworldField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
  }
  
  private func setUpView() {
    self.signinLabel.textColor = Colors.white
    self.view.backgroundColor = Colors.background
  }
  
  @IBAction func signinAction(_ sender: PrimaryButton) {
    guard let user = self.usernameField.text, user.isValidEmail() else {
      self.delegate?.emailValidationError()
      return
    }
    
    guard let password = self.passworldField.text, !password.isEmpty else {
      self.delegate?.passwordEmpty()
      return
    }
    
    self.delegate?.signin(user: user, password: password)
  }
}
