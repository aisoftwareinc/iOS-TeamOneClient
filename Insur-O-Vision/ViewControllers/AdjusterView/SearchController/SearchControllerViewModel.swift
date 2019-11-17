//
//  SearchControllerViewModel.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/10/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation
import Asterism

class SearchControllerViewModel {
  let userID: String
  
  var results = [Claim]()
  
  enum State {
    typealias Index = Int
    case fetchedClaims
    case fetchFailed(Error)
    case empty
  }
  
  var callBack: (State) -> ()?
  
  init(_ userID: String, callBack: @escaping (State) -> ()) {
    self.userID = userID
    self.callBack = callBack
  }
  
  func search(_ term: String) {
    Networking.send(SearchClaimsRequest(userID: userID, searchTerm: term)) { (result: Result<ListClaimsResult, Error>) in
      switch result {
      case .success(let claimsResult):
        DLOG("Search Claims \\n Count: \(claimsResult.claims.count): \\n \(claimsResult.claims)")
        self.results = claimsResult.claims
        self.results.count == 0 ? self.callBack(.empty) : self.callBack(.fetchedClaims)
      case .failure(let error):
        DLOG("Search Error \(error)")
        self.callBack(.fetchFailed(error))
      }
    }
  }
}
