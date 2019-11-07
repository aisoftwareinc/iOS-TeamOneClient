//
//  ClaimsListController.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/5/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import UIKit

class ClaimsListController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  let claimsViewModel: ClaimsListViewModel
  
  init(_ userID: String) {
    claimsViewModel = ClaimsListViewModel(userID: userID, callBack: { state in
      
    })
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    claimsViewModel.fetchClaims()
    // Do any additional setup after loading the view.
  }

  
}
