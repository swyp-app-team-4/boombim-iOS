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
        let image = UIImage(named: "kakao_login_large_wide") // 등록한 이름과 일치
        self.setBackgroundImage(image, for: .normal)
        self.adjustsImageWhenHighlighted = false // 눌렸을 때 흐려지는 효과 제거
    }
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupUI()
//    }
//
//    private func setupUI() {
//        self.setTitle("카카오로 로그인", for: .normal)
//        self.setTitleColor(.black, for: .normal)
//        self.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
//        self.backgroundColor = UIColor(hex: "#FEE500")
//        self.layer.cornerRadius = 8
//        self.clipsToBounds = true
//
//        // 로고 이미지 추가 (선택)
//        let logo = UIImageView(image: UIImage(named: "kakao_logo")) // 앱에 로고 이미지 포함해야 함
//        logo.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(logo)
//
//        NSLayoutConstraint.activate([
//            logo.centerYAnchor.constraint(equalTo: self.centerYAnchor),
//            logo.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
//            logo.widthAnchor.constraint(equalToConstant: 20),
//            logo.heightAnchor.constraint(equalToConstant: 20)
//        ])
//
//        self.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
//        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
//    }
}
