//
//  ClaimsListController.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/5/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import UIKit

protocol ClaimsListDelegate: class {
  func didSelectClaim(_ streamID: String)
}

class ClaimsListController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  var claimsViewModel: ClaimsListViewModel!
  weak var delegate: ClaimsListDelegate?
  
  init(_ userID: String, _ delegate: ClaimsListDelegate) {
    super.init(nibName: nil, bundle: nil)
    claimsViewModel = ClaimsListViewModel(userID: userID, callBack: handleCallback)
    self.delegate = delegate
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    claimsViewModel.fetchClaims()
    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.tableView.register(UINib(nibName: "ClaimsCell", bundle: nil), forCellReuseIdentifier: "ClaimsCell")
    self.view.backgroundColor = Colors.background
    self.tableView.tableFooterView = UIView()
    self.tableView.backgroundColor = Colors.background
  }

  func handleCallback(_ state: ClaimsListViewModel.State) {
    switch state {
    case .fetchedClaims:
      UI { self.tableView.reloadData() }
    case .fetchFailed(let error):
      DLOG("Error \(error)")
    }
  }
}

extension ClaimsListController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return claimsViewModel.claims.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let claim = claimsViewModel.claims[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "ClaimsCell", for: indexPath) as! ClaimsCell
    cell.configure(claim)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let claim = claimsViewModel.claims[indexPath.row]
    delegate?.didSelectClaim(claim.streamid)
  }
  
  
}
