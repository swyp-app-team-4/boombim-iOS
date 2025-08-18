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
        backgroundColor = UIColor(hex: "#FEE500")  // 공식 카카오 노란색
        setTitle("login.button.kakao".localized(), for: .normal)
        setTitleColor(.black, for: .normal)
        titleLabel?.font = Typography.Body01.medium.font
        
        setImage(UIImage(named: "kakao_logo"), for: .normal)
        imageView?.contentMode = .scaleAspectFit
        
        semanticContentAttribute = .forceLeftToRight
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        
        layer.cornerRadius = 12
        clipsToBounds = true
    }
}
