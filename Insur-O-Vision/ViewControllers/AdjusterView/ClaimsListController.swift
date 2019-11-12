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
  func pushToSelect()
  func errorRemovingClaim()
}

class ClaimsListController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  var claimsViewModel: ClaimsListViewModel!
  weak var delegate: ClaimsListDelegate?
  
  init(_ userID: String, _ delegate: ClaimsListDelegate, _ name: String) {
    super.init(nibName: nil, bundle: nil)
    claimsViewModel = ClaimsListViewModel(userID: userID, callBack: { [weak self] state in
      switch state {
      case .fetchedClaims:
        UI { self?.tableView.reloadData() }
      case .fetchFailed(let error):
        DLOG("Error \(error)")
      case .deleteSuccess(let index):
        let indexPath = IndexPath(row: index, section: 0)
        UI { self?.tableView.deleteRows(at: [indexPath], with: .automatic) }
      case .deleteFailed(_):
        DLOG("Error Removing Claim")
        self?.delegate?.errorRemovingClaim()
      }
    })
    self.delegate = delegate
    self.title = "Claims"
    self.navigationItem.prompt = name
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
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: SearchIcon.imageOfSearch, style: .plain, target: self, action: #selector(pushToSearch))
    self.navigationController?.navigationBar.barStyle = .black //Needed so Prompt is white
  }
  
  @objc
  func pushToSearch() {
    delegate?.pushToSelect()
  }
  
  deinit {
    DLOG("Claims VC Deinit...")
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
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let claim = claimsViewModel.claims[indexPath.row]
    let action = UIContextualAction(style: .destructive, title: "Mark as Complete") { (action, view, completion) in
      DLOG("\(claim.insuredname)")
      self.claimsViewModel.delete(claim.claimid)
      completion(true)
    }
    let config = UISwipeActionsConfiguration(actions: [action])
    return config
  }
}
