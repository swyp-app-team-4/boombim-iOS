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
        backgroundColor = UIColor(hex: "#03C75A") // 네이버 그린
        setTitle("login.button.naver".localized(), for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = Typography.Body01.medium.font
        
        setImage(UIImage(named: "naver_logo"), for: .normal)
        imageView?.contentMode = .scaleAspectFit
        
        semanticContentAttribute = .forceLeftToRight
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        
        layer.cornerRadius = 12
        clipsToBounds = true
    }
}
