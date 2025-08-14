//
//  KakaoLoginButton.swift
//  SwypTeam4
//
//  Created by 조영현 on 8/1/25.
//

import UIKit

final class KakaoLoginButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        let image = UIImage.buttonKakaoLogin
        self.setBackgroundImage(image, for: .normal)
    }
}
