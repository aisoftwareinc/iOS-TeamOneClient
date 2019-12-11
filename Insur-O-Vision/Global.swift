//
//  Global.swift
//  Insur-O-Vision
//
//  Created by Peter Gosling on 8/23/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import Foundation

func UI(_ closure: @escaping () -> ()) {
  DispatchQueue.main.async { closure() }
}

typealias NotesCallback = (String) -> Void
