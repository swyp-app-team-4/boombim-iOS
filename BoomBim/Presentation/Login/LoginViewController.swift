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
    private let activityIndicator = UIActivityIndicatorView(style: .large)

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
        
        setupView()
        bind()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        configureButton()
        configureTitle()
        configureActivityIndicator()
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
    
    private func configureActivityIndicator() {
        activityIndicator.hidesWhenStopped = true // stop하면 자동으로 숨김
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func bind() {
        // 1) Input 구성
        let input = LoginViewModel.Input(
            kakaoTap: kakaoButton.rx.tap.asObservable(),
            naverTap: naverButton.rx.tap.asObservable(),
            appleTap: appleButton.rx.controlEvent(.touchUpInside).asObservable(),
            withoutLoginTap: withLoginButton.rx.tap.asSignal()
        )
        
        // 2) 변환
        let output = viewModel.transform(input: input)
        
        // 3) 로딩 표시
        output.isLoading
            .drive(activityIndicator.rx.isAnimating) // UIActivityIndicatorView
            .disposed(by: disposeBag)
        
        // 로딩 중에는 버튼 비활성화 (중복 탭 방지)
        output.isLoading
            .map { !$0 }
            .drive(kakaoButton.rx.isEnabled, naverButton.rx.isEnabled, appleButton.rx.isEnabled, withLoginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 4) 에러 토스트/알럿
        output.error
            .emit(onNext: { [weak self] message in
                self?.presentAlert(title: "로그인 실패", message: message)
            })
            .disposed(by: disposeBag)
    }
    
    private func presentAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "확인", style: .default))
        present(ac, animated: true)
    }
}
