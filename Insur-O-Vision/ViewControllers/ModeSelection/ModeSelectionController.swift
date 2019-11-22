import UIKit


protocol ModeSelectionDelegate: class {
  func didSelectAdjuster()
  func didSelectInsured()
}

class ModeSelectionController: UIViewController {
  
  @IBOutlet weak var adjusterAction: PrimaryButton!
  @IBOutlet weak var insuredAction: PrimaryButton!
  
  weak var delegate: ModeSelectionDelegate?
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  init(_ delegate: ModeSelectionDelegate) {
    self.delegate = delegate
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if Defaults.value(for: Defaults.UserID) != nil {
      addLogOut()
    }
  }
  
  private func setUpView() {
    self.navigationItem.hidesBackButton = true
    self.view.backgroundColor = Colors.background
    self.title = "Dashboard"
    self.adjusterAction.tintColor = .white
    self.insuredAction.tintColor = .white
  }
  
  private func addLogOut() {
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
  }
  
  @objc
  private func logout() {
    Defaults.remove(Defaults.UserID)
    Defaults.remove(Defaults.UserName)
     self.navigationItem.rightBarButtonItem = nil
  }
  
  @IBAction func adjusterTap(_ sender: PrimaryButton) {
    delegate?.didSelectAdjuster()
  }
  
  @IBAction func insuredTap(_ sender: PrimaryButton) {
    delegate?.didSelectInsured()
  }
}
