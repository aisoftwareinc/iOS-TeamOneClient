//
//  SearchController.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/8/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import UIKit

class SearchController: UIViewController {
  
  enum State {
    case initial
    case empty
    case results
    case error
  }
  
  @IBOutlet weak var tableView: UITableView!
  var searchViewModel: SearchControllerViewModel!
  let searchController = UISearchController.init(searchResultsController: nil)
  var state: State = .initial
  
  init(_ userID: String) {
    super.init(nibName: nil, bundle: nil)
    self.title = "Claims Search"
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
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addSearchBar()
    self.tableView.dataSource = self
    self.tableView.register(UINib(nibName: "ClaimsCell", bundle: nil), forCellReuseIdentifier: "ClaimsCell")
    self.tableView.register(UINib(nibName: "GenericInfoCell", bundle: nil), forCellReuseIdentifier: "GenericInfoCell")
    self.view.backgroundColor = Colors.background
    self.tableView.tableFooterView = UIView()
    self.tableView.backgroundColor = Colors.background
    self.tableView.rowHeight = UITableView.automaticDimension
    self.tableView.estimatedRowHeight = 44.0
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


extension SearchController: UITableViewDataSource {
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
      cell.configure("Enter a term to search claims.")
      return cell
    case .empty:
      let cell = tableView.dequeueReusableCell(withIdentifier: "GenericInfoCell", for: indexPath) as! GenericInfoCell
      cell.configure("No claims found for that term.")
      return cell
    case .error:
      let cell = tableView.dequeueReusableCell(withIdentifier: "GenericInfoCell", for: indexPath) as! GenericInfoCell
      cell.configure("An error occurred searching for claims.")
      return cell
    case .results:
      let claim = searchViewModel.results[indexPath.row]
      let cell = tableView.dequeueReusableCell(withIdentifier: "ClaimsCell", for: indexPath) as! ClaimsCell
      cell.configure(claim)
      return cell
    }
  }
}
