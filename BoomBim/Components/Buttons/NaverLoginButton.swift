//
//  NaverLoginButton.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit

final class NaverLoginButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        let image = UIImage.buttonNaverLogin
        self.setBackgroundImage(image, for: .normal)
    }
}
