//
//  SearchController.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/8/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import UIKit
import Asterism

protocol SearchControllerDelegate: class {
  func didSelectClaim(_ claimID: String, _ streamID: String)
  func pushToSelect()
  func pushToImages(_ claimID: String)
  func errorRemovingClaim()
  func fetchError()
  func pushToCamera(_ claimID: String)
}

class SearchController: UIViewController {
  
  enum State {
    case initial
    case empty
    case results
    case error
  }
  
  @IBOutlet weak var tableView: UITableView!
  var searchViewModel: SearchControllerViewModel!
  private weak var delegate: SearchControllerDelegate?
  let searchController = UISearchController.init(searchResultsController: nil)
  var state: State = .initial
  
  init(_ userID: String, _ delegate: SearchControllerDelegate) {
    super.init(nibName: nil, bundle: nil)
    self.title = "Claims Search"
    self.delegate = delegate
    self.searchViewModel = SearchControllerViewModel(userID) { [weak self] state in
      switch state {
      case .fetchedClaims:
        self?.state = .results
      case .fetchFailed(_):
        self?.state = .error
      case .empty:
        self?.state = .empty
      }
      UI { self?.tableView.reloadData() }
    }
  }
  
  deinit {
    DLOG("Search VC Deinit...")
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addSearchBar()
    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.tableView.register(UINib(nibName: "ClaimsCell", bundle: nil), forCellReuseIdentifier: "ClaimsCell")
    self.tableView.register(UINib(nibName: "GenericInfoCell", bundle: nil), forCellReuseIdentifier: "GenericInfoCell")
    self.tableView.register(UINib(nibName: "GenericHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "GenericHeaderView")
    self.view.backgroundColor = Colors.background
    self.tableView.tableFooterView = UIView()
    self.tableView.backgroundColor = Colors.background
    self.tableView.rowHeight = UITableView.automaticDimension
    self.tableView.estimatedRowHeight = 44.0
    self.tableView.separatorColor = Colors.white
  }
  
  //Required or UISearchController leaks.
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.searchController.isActive = false
  }
  
  private func addSearchBar() {
    self.searchController.searchResultsUpdater = self
    self.searchController.delegate = self
    self.searchController.searchBar.delegate = self
    self.searchController.hidesNavigationBarDuringPresentation = false
    self.searchController.dimsBackgroundDuringPresentation = false
    self.definesPresentationContext = true
    self.navigationItem.searchController = searchController
    self.navigationItem.hidesSearchBarWhenScrolling = false
  }
}

extension SearchController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
  func updateSearchResults(for searchController: UISearchController) { }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    if let term = searchBar.text {
      searchViewModel.search(term)
    }
  }
}


extension SearchController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch state {
    case .initial:
      return 1
    case .empty:
      return 1
    case .error:
      return 1
    case .results:
      return searchViewModel.results.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch state {
    case .initial:
      let cell = tableView.dequeueReusableCell(withIdentifier: "GenericInfoCell", for: indexPath) as! GenericInfoCell
      cell.configure("Enter a term")
      cell.separatorInset = UIEdgeInsets(top: 0, left: -10000, bottom: 0, right: 0)
      cell.isUserInteractionEnabled = false
      return cell
    case .empty:
      let cell = tableView.dequeueReusableCell(withIdentifier: "GenericInfoCell", for: indexPath) as! GenericInfoCell
      cell.configure("No claims found for that term.")
      cell.isUserInteractionEnabled = false
      return cell
    case .error:
      let cell = tableView.dequeueReusableCell(withIdentifier: "GenericInfoCell", for: indexPath) as! GenericInfoCell
      cell.configure("An error occurred searching for claims.")
      cell.isUserInteractionEnabled = false
      return cell
    case .results:
      let claim = searchViewModel.results[indexPath.row]
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
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let claim = searchViewModel.results[indexPath.row]
    delegate?.didSelectClaim(claim.claimid, claim.streamid)
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 65
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "GenericHeaderView") as! GenericHeaderView
    headerView.headerLabel.text = "Valid Search Fields: Zip Code, Claim ID,\nInsured name/address"
    return headerView
  }
}
