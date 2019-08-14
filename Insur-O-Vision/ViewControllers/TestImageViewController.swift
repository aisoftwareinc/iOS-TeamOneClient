//
//  TestImageViewController.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 8/13/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import UIKit

class TestImageViewController: UIViewController {
  
  @IBOutlet weak var imageView: UIImageView!
  private let image: UIImage
  
  init(_ image: UIImage) {
    self.image = image
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.imageView.image = image
    // Do any additional setup after loading the view.
  }
}
