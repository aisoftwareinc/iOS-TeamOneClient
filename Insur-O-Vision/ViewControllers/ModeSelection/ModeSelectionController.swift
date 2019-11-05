import UIKit


protocol ModeSelectionDelegate: class {
  func didSelectAdjuster()
  func didSelectInsured()
}

class ModeSelectionController: UIViewController {
  
  @IBOutlet weak var adjusterAction: PrimaryButton!
  @IBOutlet weak var insuredAction: PrimaryButton!
  @IBOutlet weak var modeTitle: UILabel!
  
  weak var delegate: ModeSelectionDelegate?
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpView()
  }
  
  private func setUpView() {
    self.navigationItem.hidesBackButton = true
    self.view.backgroundColor = Colors.background
    self.modeTitle.textColor = Colors.white
    self.title = "Team One"
  }
  @IBAction func adjusterTap(_ sender: PrimaryButton) {
    delegate?.didSelectAdjuster()
  }
  
  @IBAction func insuredTap(_ sender: PrimaryButton) {
    delegate?.didSelectInsured()
  }
}
