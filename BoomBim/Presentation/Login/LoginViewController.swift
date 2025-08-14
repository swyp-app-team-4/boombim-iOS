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

    // MARK: - UI
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 12
        
        return stackView
    }()
    
    private let withLoginButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.setText("login.button.without_login".localized(), style: Typography.Caption.regular, color: .gray)
        
        button.backgroundColor = .clear
        return button
    }()
    
    private let kakaoButton = KakaoLoginButton()
    private let naverButton = NaverLoginButton()
    private let appleButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
    
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
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        configureButton()
    }
    
    private func configureButton() {
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        
        [kakaoButton, naverButton, appleButton, withLoginButton].forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            
            buttonStackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            
            
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
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
                case .success(let tokenInfo):
                    print("로그인 성공: \(tokenInfo)")
                    // 백엔드에 token 전달
                    TokenManager.shared.save(tokenInfo: tokenInfo) // UserDefaults 저장
                    self.viewModel.didLoginSuccess?() // 화면 이동
                case .failure(let error):
                    print("로그인 실패: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
}
