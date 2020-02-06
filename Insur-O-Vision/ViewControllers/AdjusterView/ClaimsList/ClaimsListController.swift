//
//  ClaimsListController.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/5/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import UIKit
import Asterism

protocol ClaimsListDelegate: class {
  func didSelectClaim(_ claimID: String, _ streamID: String)
  func pushToSelect()
  func pushToImages(_ claimID: String)
  func errorRemovingClaim()
  func fetchError()
  func pushToCamera(_ claimID: String)
}

class ClaimsListController: UIViewController {
  
  enum State {
    case initial
    case empty
    case results
    case error
  }
  
  @IBOutlet weak var tableView: UITableView!
  var claimsViewModel: ClaimsListViewModel!
  private weak var delegate: ClaimsListDelegate?
  private var refreshControl: UIRefreshControl!
  
  var state: State = .initial
  
  init(_ userID: String, _ delegate: ClaimsListDelegate, _ name: String) {
    super.init(nibName: nil, bundle: nil)
    claimsViewModel = ClaimsListViewModel(userID: userID, callBack: { [weak self] state in
      UI { self?.refreshControl.endRefreshing() }
      switch state {
      case .fetchedClaims:
        self?.state = .results
        UI {
          self?.tableView.reloadData()
        }
      case .empty:
        self?.state = .empty
        UI {
          self?.tableView.reloadData()
        }
      case .fetchFailed(let error):
        self?.state = .error
        UI {
          self?.tableView.reloadData()
        }
        DLOG("Error fetching claims: \(error)")
      case .deleteSuccess(let index):
        let indexPath = IndexPath(row: index, section: 0)
        UI { self?.tableView.deleteRows(at: [indexPath], with: .automatic) }
      case .deleteFailed(_):
        DLOG("Error Removing Claim")
        UI { self?.delegate?.errorRemovingClaim() }
      }
    })
    self.delegate = delegate
    self.title = "Claims List"
    self.navigationItem.prompt = name
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.tableView.register(UINib(nibName: "GenericInfoCell", bundle: nil), forCellReuseIdentifier: "GenericInfoCell")
    self.tableView.register(UINib(nibName: "ClaimsCell", bundle: nil), forCellReuseIdentifier: "ClaimsCell")
    self.tableView.register(UINib(nibName: "GenericHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "GenericHeaderView")
    self.view.backgroundColor = Colors.background
    self.tableView.tableFooterView = UIView()
    self.tableView.backgroundColor = Colors.background
    self.tableView.rowHeight = UITableView.automaticDimension
    self.tableView.estimatedRowHeight = 44.0
    self.tableView.separatorColor = Colors.white
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: SearchIcon.imageOfSearch, style: .plain, target: self, action: #selector(pushToSearch))
    self.navigationController?.navigationBar.barStyle = .black //Needed so Prompt is white text
    
    //Refresh Control settings
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    refreshControl.tintColor = .white
    tableView.refreshControl = refreshControl
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    claimsViewModel.fetchClaims()
  }
  
  
  @objc
  func pushToSearch() {
    delegate?.pushToSelect()
  }
  
  deinit {
    DLOG("Claims VC Deinit...")
  }
  
  @objc
  func refresh() {
    claimsViewModel.fetchClaims()
  }
}

extension ClaimsListController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    switch state {
    case .empty:
      return 1
    case .initial:
      return 1
    case .results:
      return claimsViewModel.claims.count
    case .error:
      return 1
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    switch state {
    case .initial:
      let cell = tableView.dequeueReusableCell(withIdentifier: "GenericInfoCell", for: indexPath) as! GenericInfoCell
      cell.configure("Fetching Claims...")
      cell.isUserInteractionEnabled = false
      return cell
    case .empty:
      let cell = tableView.dequeueReusableCell(withIdentifier: "GenericInfoCell", for: indexPath) as! GenericInfoCell
      cell.configure("No claims found for user...")
      cell.isUserInteractionEnabled = false
      return cell
    case .results:
      let claim = claimsViewModel.claims[indexPath.row]
      let cell = tableView.dequeueReusableCell(withIdentifier: "ClaimsCell", for: indexPath) as! ClaimsCell
      cell.cameraAction = { [weak self] in
        self?.delegate?.pushToCamera(claim.claimid)
      }
      
      cell.allImagesAction = { [weak self] in
        self?.delegate?.pushToImages(claim.claimid)
      }
      
      cell.videoAction = { [weak self] in
        self?.delegate?.didSelectClaim(claim.claimid, claim.streamid)
      }
      cell.configure(claim)
      return cell
    case .error:
      let cell = tableView.dequeueReusableCell(withIdentifier: "GenericInfoCell", for: indexPath) as! GenericInfoCell
      cell.configure("An error occured. Pull down to Try Again.")
      cell.isUserInteractionEnabled = false
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
  }
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let claim = claimsViewModel.claims[indexPath.row]
    return self.claimsViewModel.swipeAction(claim)
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 50
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "GenericHeaderView") as! GenericHeaderView
    headerView.headerLabel.text = "Swipe left to remove claim from list"
    return headerView
  }
}
