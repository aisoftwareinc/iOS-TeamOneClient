import UIKit
import Asterism

protocol ImageListDelegate: class {
  func didSelectImage(_ details: PhotoDetail, claimID: String)
}

class ImageListController: UIViewController {
  
  @IBOutlet weak var collectionView: UICollectionView!
  private var viewModel: ImageListControlerViewModel!
  private let claimID: String
  private weak var delegate: ImageListDelegate?
  
  init(_ claimID: String, _ delegate: ImageListDelegate) {
    self.claimID = claimID
    self.delegate = delegate
    super.init(nibName: nil, bundle: nil)
    self.title = "Image List"
    self.viewModel = ImageListControlerViewModel({ (state) in
      switch state {
      case .fetchedImage(_):
        UI { self.collectionView.reloadData() }
      case .noPhotos:
        break
      case .errorFetching:
        break
      }
    })
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    prepCollectionView()
    viewModel.fetchSavedPhotos(for: claimID)
  }
  
  private func prepCollectionView() {
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    self.collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
    self.collectionView.backgroundColor = Colors.background
  }
  
}

extension ImageListController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.photos.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let photo = viewModel.photos[indexPath.row]
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
    cell.configure(photo.thumbnail, photo.title)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let photo = viewModel.photos[indexPath.row]
    delegate?.didSelectImage(photo, claimID: claimID)
  }
}

extension UIImageView {
  func fetchImage(for link: String, _ placeHolder: UIImage? = nil, _ failureImage: UIImage? = nil) {
    self.image = placeHolder
    Networking.send(ImageRequest(link)) { (result: Result<Data, Error>) in
      switch result {
      case .success(let data):
        guard let image = UIImage(data: data) else {
          UI { self.image = failureImage }
          return
        }
        UI { self.image = image }
      case .failure(let error):
        DLOG(error.localizedDescription)
        UI { self.image = failureImage }
      }
    }
  }
}
