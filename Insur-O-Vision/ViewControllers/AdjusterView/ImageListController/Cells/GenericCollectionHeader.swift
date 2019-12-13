import UIKit

class GenericCollectionHeader: UICollectionReusableView {
  
  @IBOutlet weak var background: UIView!
  @IBOutlet weak var headerLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.background.backgroundColor = Colors.secondaryBackground
    headerLabel.textColor = Colors.white
  }
  
}
