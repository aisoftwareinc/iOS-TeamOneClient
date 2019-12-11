//
//  ImageListControlerVIewModel.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 12/10/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation
import Asterism

class ImageListControlerViewModel {
  
  enum State {
    case fetchedImage([PhotoDetail])
    case noPhotos
    case errorFetching
  }
  
  let callback: (State) -> Void
  
  init(_ callback: @escaping (State) -> Void) {
    self.callback = callback
  }
  
  func fetchImages(for claim: String) {
    Networking.send(ListImagesRequest(claimID: claim)) { (result: Result<ListImagesResponse, Error>) in
      switch result {
      case .success(let response):
        DLOG("Success fetching photos.")
        response.photos.count == 0 ? self.callback(.noPhotos) : self.callback(.fetchedImage(response.photos))
      case .failure(let error):
        DLOG("Fetching Image Error \(error)")
        self.callback(.errorFetching)
      }
    }
  }
}
