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
    private let titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 32
        
        return stackView
    }()
    
    private let loginTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.setStyledText(
            fullText: "login.label.title".localized(), highlight: "login.label.title.highlight".localized(),
            font: .taebaek(size: 32), highlightFont: .taebaek(size: 32),
            color: UIColor(hex: "#0F0F10"), highlightColor: .main)
        
        return label
    }()
    
    private let loginTitleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.illustrationLogin
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 12
        
        return stackView
    }()
    
    private let bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.bubbleInfo
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let kakaoButton = KakaoLoginButton()
    private let naverButton = NaverLoginButton()
    private let appleButton: UIControl = {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.cornerRadius = 12
        
        return button
    }()
    
    private let withLoginButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("login.button.without_login".localized(), for: .normal)
        button.titleLabel?.font = Typography.Caption.regular.font
        button.setTitleColor(UIColor(hex: "#70737C"), for: .normal)
        button.setUnderline(underlineColor: UIColor(hex: "#70737C"), spacing: 4)
        
        button.backgroundColor = .clear
        return button
    }()
    
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
        configureTitle()
        
    }
    
    private func configureTitle() {
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleStackView)
        
        [loginTitleLabel, loginTitleImageView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            titleStackView.addArrangedSubview(view)
        }
        
        NSLayoutConstraint.activate([
            titleStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70),
//            titleStackView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -44),
            titleStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func configureButton() {
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        
        [bubbleImageView, kakaoButton, naverButton, appleButton, withLoginButton].forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            
            buttonStackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            kakaoButton.heightAnchor.constraint(equalToConstant: 56),
            naverButton.heightAnchor.constraint(equalToConstant: 56),
            appleButton.heightAnchor.constraint(equalToConstant: 56),
            
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70),
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
