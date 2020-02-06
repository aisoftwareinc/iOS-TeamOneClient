//
//  ImageListControlerVIewModel.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 12/10/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation
import Asterism
import UIKit

class ImageListControlerViewModel {
  
  enum State {
    case fetchedImage([PhotoDetail])
    case noPhotos
    case errorFetching
  }
  
  var photos = [PhotoDetail]()
  
  let callback: (State) -> Void
  
  init(_ callback: @escaping (State) -> Void) {
    self.callback = callback
  }
  
  func fetchSavedPhotos(for claim: String) {
    Networking.send(ListImagesRequest(claimID: claim)) { (result: Result<ListImagesResponse, Error>) in
      switch result {
      case .success(let response):
        DLOG("Success fetching photos.")
        response.photos.count == 0 ? self.callback(.noPhotos) : self.callback(.fetchedImage(response.photos))
        self.photos = response.photos
      case .failure(let error):
        DLOG("Fetching Image Error \(error)")
        self.callback(.errorFetching)
      }
    }
  }
  
  func fetchImage(_ link: String, _ completion: @escaping (Result<Data, Error>) -> Void) {
    Networking.send(ImageRequest(link)) { (result: Result<Data, Error>) in
      completion(result)
    }
  }
  
  func buildPhotoBook(for claim: String) {
    Networking.send(BuildPhotoBook(claimID: claim))
  }
}
