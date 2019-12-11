import Foundation
import UIKit

class PrimaryTextView: UITextView {
  init() {
    super.init(frame: .zero, textContainer: nil)
    self.layer.cornerRadius = 4.0
    self.layer.borderColor = Colors.primary.cgColor
    self.layer.borderWidth = 1.0
    self.backgroundColor = UIColor.clear
    self.textColor = UIColor.white
    self.tintColor = .white
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.layer.cornerRadius = 4.0
    self.layer.borderColor = Colors.primary.cgColor
    self.backgroundColor = UIColor.clear
    self.layer.borderWidth = 1.0
    self.textColor = UIColor.white
    self.tintColor = .white
  }
}
