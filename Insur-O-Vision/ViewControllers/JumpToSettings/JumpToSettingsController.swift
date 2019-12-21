import UIKit

class JumpToSettingsController: UIViewController {
  
  @IBOutlet weak var descriptionText: UILabel!
  @IBOutlet weak var settingsButton: PrimaryButton!
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Location Services"
    self.navigationItem.hidesBackButton = true
    self.descriptionText.textColor = Colors.white
    self.view.backgroundColor = Colors.background
    
  }
  
  @IBAction func openSettings(_ sender: Any) {
    if let url = URL(string: UIApplication.openSettingsURLString) {
      UIApplication.shared.open(url, options: [:], completionHandler: { success in
        fatalError()
      })
    }
  }
}
