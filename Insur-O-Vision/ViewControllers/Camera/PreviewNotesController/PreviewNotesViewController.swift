
import UIKit
import Asterism

protocol PreviewNotesDelegate: class {
  func addNotes(_ callback: @escaping NotesCallback, _ existingNotes: String?)
  func submit(_ base64Image: String, _ title: String, _ notes: String, _ claimID: String)
}

class PreviewNotesViewController: UIViewController {
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var notesLabel: UILabel!
  @IBOutlet weak var submit: PrimaryButton!
  @IBOutlet weak var roundedView: UIView!
  @IBOutlet weak var chevron: UIImageView!
  @IBOutlet weak var addNotesLabel: UILabel!
  @IBOutlet weak var titleTextField: PrimaryTextField!
  
  private let imageData: Data
  private var notes: String?
  private var imageTitle: String?
  private var claimID: String
  private weak var delegate: PreviewNotesDelegate?
  
  init(_ image: Data, _ claimID: String, title: String?, notes: String?, delegate: PreviewNotesDelegate) {
    self.imageData = image
    self.notes = notes
    self.delegate = delegate
    self.imageTitle = title
    self.claimID = claimID
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    prepView()
  }
  
  private func prepView() {
    self.view.backgroundColor = Colors.background
    self.imageView.image = UIImage(data: imageData)
    self.titleTextField.text = self.imageTitle
    self.roundedView.layer.cornerRadius = 4.0
    self.roundedView.layer.backgroundColor = Colors.secondaryBackground.cgColor
    self.notesLabel.textColor = Colors.white
    self.addNotesLabel.textColor = Colors.primary
    self.notesLabel.text = notes ?? "No Notes..."
    self.chevron.tintColor = Colors.white
    self.title = "Preivew Image"
    addTapRecognizer()
    addKeyboardDismissTap()
  }
  
  private func addKeyboardDismissTap() {
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(gesture)
  }
  
  @objc
  func dismissKeyboard() {
    UI { self.titleTextField.resignFirstResponder() }
  }
  
  private func addTapRecognizer() {
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(addNotesAction))
    roundedView.addGestureRecognizer(tapRecognizer)
  }
  
  @IBAction func addNotesAction(_ sender: Any) {
    delegate?.addNotes({ [weak self] notes in
      self?.notes = notes
      self?.notesLabel.text = notes
      }, self.notes)
  }
  
  @IBAction func submitAction(_ sender: PrimaryButton) {
    let base64Image = imageData.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .urlImageEncoded)!
    delegate?.submit(base64Image, self.titleTextField.text ?? "HubOne Photo", self.notes ?? "", claimID)
  }
}
