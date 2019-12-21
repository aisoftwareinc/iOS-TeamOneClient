import UIKit
import Asterism

protocol ImageListDelegate: class {
  func didSelectImage(_ details: PhotoDetail, claimID: String)
}

class ImageListController: UIViewController {
  
  enum State {
    case photos
    case fetching
    case noPhotos
    case error
  }
  
  @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
  @IBOutlet weak var collectionView: UICollectionView!
  private var viewModel: ImageListControlerViewModel!
  private let claimID: String
  private weak var delegate: ImageListDelegate?
  private var state: State = .fetching
  private var refreshControl: UIRefreshControl!
  
  init(_ claimID: String, _ delegate: ImageListDelegate) {
    self.claimID = claimID
    self.delegate = delegate
    super.init(nibName: nil, bundle: nil)
    self.title = "Image List"
    self.viewModel = ImageListControlerViewModel({ [weak self] (state) in
      UI { self?.refreshControl.endRefreshing() }
      switch state {
      case .fetchedImage(_):
        self?.state = .photos
      case .noPhotos:
        self?.state = .noPhotos
      case .errorFetching:
        self?.state = .error
      }
      UI { self?.collectionView.reloadData() }
    })
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    prepCollectionView()
    viewModel.fetchSavedPhotos(for: claimID)
    
    //Refresh Control settings
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    refreshControl.tintColor = .white
    collectionView.refreshControl = refreshControl
    view.backgroundColor = Colors.background
  }
  
    @objc
  func refresh() {
    viewModel.fetchSavedPhotos(for: claimID)
  }
  
  private func prepCollectionView() {
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    self.collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
    self.collectionView.register(UINib(nibName: "GenericCollectionHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "GenericCollectionHeader")
    flowLayout.headerReferenceSize = CGSize(width: self.collectionView.frame.size.width, height: 44)
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
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    switch state {
    case .photos:
      let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "GenericCollectionHeader", for: indexPath) as! GenericCollectionHeader
      headerView.headerLabel.text = "Available Photos"
      return headerView
    case .fetching:
      let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "GenericCollectionHeader", for: indexPath) as! GenericCollectionHeader
      headerView.headerLabel.text = "Fetching Photos..."
      return headerView
    case .noPhotos:
      let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "GenericCollectionHeader", for: indexPath) as! GenericCollectionHeader
      headerView.headerLabel.text = "No Photos Available"
      return headerView
    case .error:
      let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "GenericCollectionHeader", for: indexPath) as! GenericCollectionHeader
      headerView.headerLabel.text = "Error Fetching Photos"
      return headerView
    }
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
