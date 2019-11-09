//
//  ClaimsListViewModel.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/6/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation

class ClaimsListViewModel {
  
  enum State {
    case fetchedClaims
    case fetchFailed(Error)
  }
  
  let userID: String
  var callBack: (State) -> ()?
  init(userID: String, callBack: @escaping (State) -> ()) {
    self.userID = userID
    self.callBack = callBack
  }
  var claims = [Claim]()
  
  func fetchClaims() {
    Networking.send(ListClaimsRequest(userID: userID)) { (result: Result<ListClaimsResult, Error>) in
      switch result {
      case .success(let claims):
        self.claims = claims.claims
        self.callBack(.fetchedClaims)
      case .failure(let error):
        self.callBack(.fetchFailed(error))
      }
    }
  }
  
  func delete(_ claim: String) {
    
  }
  
  
}
