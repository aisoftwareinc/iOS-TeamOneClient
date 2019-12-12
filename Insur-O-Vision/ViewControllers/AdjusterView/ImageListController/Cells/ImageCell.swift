import UIKit

class ImageCell: UICollectionViewCell {
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var blurView: UIVisualEffectView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.layer.cornerRadius = 5.0
    self.blurView.layer.cornerRadius = 3.0
    self.blurView.clipsToBounds = true
  }
  
  func configure(_ link: String, _ title: String) {
    self.imageView.fetchImage(for: link)
    self.title.text = title
  }
  
}
