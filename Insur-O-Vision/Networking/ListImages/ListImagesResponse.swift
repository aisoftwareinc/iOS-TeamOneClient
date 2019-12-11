import Foundation

struct ListImagesResponse: Decodable {
  let photos: [PhotoDetail]
}

struct PhotoDetail: Decodable {
  let id: String
  let title: String
  let caption: String
  let image: String
  let thumbnail: String
}
