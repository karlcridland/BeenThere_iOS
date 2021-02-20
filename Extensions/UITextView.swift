//
//  UITextView.swift
//  waitt
//
//  Created by Karl Cridland on 25/05/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

extension UITextView{
    
    func pos() -> Int? {
        if let selectedRange = self.selectedTextRange {
            return self.offset(from: self.beginningOfDocument, to: selectedRange.start)
        }
        return nil
    }
    
}
