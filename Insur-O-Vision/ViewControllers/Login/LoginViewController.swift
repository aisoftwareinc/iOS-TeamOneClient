//
//  LoginViewController.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/5/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import UIKit

protocol LoginViewDelegate: class {
  func signin(user: String, password: String, rememberMe: Bool)
  func emailValidationError()
  func passwordEmpty()
}

class LoginViewController: UIViewController {
  
  @IBOutlet weak var usernameField: PrimaryTextField!
  @IBOutlet weak var passworldField: PrimaryTextField!
  @IBOutlet weak var signinButton: PrimaryButton!
  @IBOutlet weak var rememberMe: UISwitch!
  @IBOutlet weak var signInLabel: UILabel!
  
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
    self.view.backgroundColor = Colors.background
    usernameField.attributedPlaceholder = NSAttributedString(string: "Email Address", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    passworldField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    self.signInLabel.textColor = Colors.white
    addEmailImage()
    addPasswordImage()
  }
  
  private func addEmailImage() {
    let emailImage = #imageLiteral(resourceName: "Email")
    let imageView = UIImageView(image: emailImage)
    imageView.contentMode = .scaleAspectFit
    imageView.frame = CGRect(x: 12.0, y: 5.0, width: 20.0, height: 20.0)
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
    view.addSubview(imageView)
    usernameField.leftView = view
    usernameField.leftViewMode = .always
  }
  
  private func addPasswordImage() {
    let passwordImage = #imageLiteral(resourceName: "Password")
    let imageView = UIImageView(image: passwordImage)
    imageView.contentMode = .scaleAspectFit
    imageView.frame = CGRect(x: 12.0, y: 5.0, width: 20.0, height: 20.0)
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
    view.addSubview(imageView)
    passworldField.leftView = view
    passworldField.leftViewMode = .always
  }
  
  private func setUpView() {
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
    
    self.delegate?.signin(user: user, password: password, rememberMe: rememberMe.isOn)
  }
}
