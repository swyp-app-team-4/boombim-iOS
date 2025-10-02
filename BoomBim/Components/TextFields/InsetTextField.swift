//
//  InsetTextField.swift
//  BoomBim
//
//  Created by 조영현 on 8/18/25.
//

import UIKit

class InsetTextField: UITextField {
    private let padding = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
