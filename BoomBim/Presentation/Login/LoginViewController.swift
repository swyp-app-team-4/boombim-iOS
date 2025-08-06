//
//  LoginViewController.swift
//  SwypTeam4
//
//  Created by 조영현 on 8/1/25.
//

import UIKit
import RxSwift
import NidThirdPartyLogin
import AuthenticationServices

final class LoginViewController: UIViewController {
    private let viewModel: LoginViewModel
    private let disposeBag = DisposeBag()

    private let kakaoButton = KakaoLoginButton()
    private let naverButton = NaverLoginButton()
    private let appleButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("loginViewcontroller")
        
        setupUI()
        bind()
        
        // 네이버 로그인 초기화 용
//        NidOAuth.shared.disconnect { [weak self] result in
//            switch result {
//            case .success:
//                print("disconnect result : \(result)")
//            case .failure(let error):
//                print("disconnect error : \(error)")
//            }
//        }
    }
    
    private func setupUI() {
        [kakaoButton, naverButton, appleButton].forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(button)
        }
        
        NSLayoutConstraint.activate([
            kakaoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            kakaoButton.bottomAnchor.constraint(equalTo: naverButton.topAnchor, constant: -20),
//            kakaoButton.widthAnchor.constraint(equalToConstant: 300),
//            kakaoButton.heightAnchor.constraint(equalToConstant: 45),
            
            naverButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            naverButton.bottomAnchor.constraint(equalTo: appleButton.topAnchor, constant: -20),
//            naverButton.widthAnchor.constraint(equalToConstant: 300),
//            naverButton.heightAnchor.constraint(equalToConstant: 45)
            
            appleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
        ])
    }
    
    private func bind() {
        let input = LoginViewModel.Input(
            kakaoTap: kakaoButton.rx.tap.asObservable(),
            naverTap: naverButton.rx.tap.asObservable(),
            appleTap: appleButton.rx.controlEvent(.touchUpInside).asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.loginResult
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { result in
                switch result {
                case .success(let token):
                    print("로그인 성공: \(token)")
                    // 백엔드에 token 전달
                    self.viewModel.didLoginSuccess?() // 화면 이동
                    // UserDefaults 저장
                    TokenManager.shared.accessToken = token
                case .failure(let error):
                    print("로그인 실패: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
}
