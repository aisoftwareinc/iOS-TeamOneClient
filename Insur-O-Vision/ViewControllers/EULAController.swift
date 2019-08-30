//
//  EULAController.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 8/11/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import UIKit
import WebKit

protocol EULADelegate: class {
  func didAccept()
  func didCancel()
}

class EULAController: UIViewController {

  @IBOutlet weak var webView: WKWebView!
  weak var delegate: EULADelegate?
  
  init(delegate: EULADelegate) {
    self.delegate = delegate
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Terms and Conditions"
  }
  @IBAction func cancel(_ sender: PrimaryButton) {
    delegate?.didCancel()
  }

  
  @IBAction func didAccept(_ sender: PrimaryButton) {
    delegate?.didAccept()
  }
}
