//
//  NotesController.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 12/9/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import UIKit
import Asterism

class NotesController: UIViewController {

  @IBOutlet weak var textView: PrimaryTextView!
  
  var notes: String?
  let notesCallback: NotesCallback
  
  init(_ callback: @escaping NotesCallback, _ notes: String?) {
    notesCallback = callback
    self.notes = notes
    super.init(nibName: nil, bundle: nil)
    self.view.backgroundColor = Colors.background
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    DLOG("NotesController deinit")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.textView.text = notes
  }
  
  @IBAction func submitNotes(_ sender: UIButton) {
    notesCallback(textView.text ?? "")
    self.navigationController?.popViewController(animated: true)
  }
  
}
