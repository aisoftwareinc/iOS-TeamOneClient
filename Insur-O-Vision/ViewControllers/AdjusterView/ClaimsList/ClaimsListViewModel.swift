//
//  ClaimsListViewModel.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 11/6/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation
import Asterism
import UIKit

class ClaimsListViewModel {
  
  enum State {
    typealias Index = Int
    case fetchedClaims
    case empty
    case fetchFailed(Error)
    case deleteSuccess(Index)
    case deleteFailed(Error)
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
        self.claims.isEmpty ? self.callBack(.empty) : self.callBack(.fetchedClaims)
      case .failure(let error):
        self.callBack(.fetchFailed(error))
      }
    }
  }
  
  func delete(_ claimID: String) {
    Networking.send(RemoveClaimRequest(claimID: claimID)) { (result: Result<SuccessFailureResult, Error>) in
      switch result {
      case .success(let state):
        switch state.result {
        case .success:
          if let index = self.claims.firstIndex(where: { (claim) -> Bool in
            return claim.claimid == claimID
          }) {
            self.claims.remove(at: index)
            self.callBack(.deleteSuccess(index))
            return
          }
          self.callBack(.deleteFailed(NSError()))
        case .failure:
          self.callBack(.deleteFailed(NSError()))
        }
      case .failure(let error):
        self.callBack(.deleteFailed(error))
      }
    }
  }
  
  func swipeAction(_ claim: Claim) -> UISwipeActionsConfiguration {
    let action = UIContextualAction(style: .destructive, title: "Mark as Complete") { (action, view, completion) in
      DLOG("\(claim.insuredname)")
      self.delete(claim.claimid)
      completion(true)
    }
    let config = UISwipeActionsConfiguration(actions: [action])
    return config
  }
}
