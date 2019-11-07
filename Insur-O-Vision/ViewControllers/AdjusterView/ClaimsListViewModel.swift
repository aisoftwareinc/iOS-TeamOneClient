//
//  ClaimsListViewModel.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/6/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation

struct ClaimsListViewModel {
  
  enum ViewModelState {
    case fetchedClaims([Claim])
  }
  
  let userID: String
  
  var callBack: (ViewModelState) -> ()?
  
  func fetchClaims() {
    Networking.send(ListClaimsRequest(userID: userID)) { (result: Result<ListClaimsResult, Error>) in
      switch result {
      case .success(let claims):
        DLOG("\(claims)")
        self.callBack(.fetchedClaims(claims.claims))
      case .failure(let error):
        DLOG("Failed \(error)")
      }
    }
  }
  
  
}
