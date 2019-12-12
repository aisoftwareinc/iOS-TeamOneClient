import Foundation
import UIKit
import Anchorage

func UI(_ closure: @escaping () -> ()) {
  DispatchQueue.main.async { closure() }
}

typealias NotesCallback = (String) -> Void


extension UIViewController {
  func applyLoader() {
    let loader = UIActivityIndicatorView()
    let overlay = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    overlay.frame = view.frame
    overlay.contentView.addSubview(loader)
    loader.centerYAnchor == overlay.centerYAnchor
    loader.centerXAnchor == overlay.centerXAnchor
    loader.startAnimating()
    loader.style = .whiteLarge
    view.addSubview(overlay)
  }
  
  func removeLoader() {
    view.subviews.forEach { view in
      if view is UIVisualEffectView {
        view.removeFromSuperview()
      }
    }
  }
}
