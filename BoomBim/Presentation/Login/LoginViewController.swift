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

final class LoginViewController: BaseViewController {
    private let viewModel: LoginViewModel
    private let disposeBag = DisposeBag()

    // MARK: - UI
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let totalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
//        stackView.spacing = 44
        
        return stackView
    }()
    
    private let spacerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()

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
            fullText: "login.label.title".localized(),
            highlight: "login.label.title.highlight".localized(),
            baseStyle: Typography.Taebaek.regular,
            highlightFont: Typography.Taebaek.regular.font,
            baseColor: .grayScale10,
            highlightColor: .main)
        
        return label
    }()
    
    private let loginTitleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.illustrationLogin
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let buttonContainerView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 17
        
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
    
    // 로그인 없이 사용하는 기능 제거
    private let withLoginButton: UIButton = {
        let button = UIButton()
        button.setTitle("login.button.without_login".localized(), for: .normal)
        button.titleLabel?.font = Typography.Caption.regular.font
        button.setTitleColor(UIColor(hex: "#70737C"), for: .normal)
        button.setUnderline(underlineColor: UIColor(hex: "#70737C"), spacing: 4)
        
        button.backgroundColor = .clear
        return button
    }()
    
    private let testButton: UIButton = {
        let button = UIButton()
        button.setTitle("test", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .yellow
        
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
        view.backgroundColor = .background
        
        configureButton()
        configureTitle()
        configureActivityIndicator()
        
        setupLayout()
    }
    
    private func configureTitle() {
        [loginTitleLabel, loginTitleImageView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            titleStackView.addArrangedSubview(view)
        }
        
        NSLayoutConstraint.activate([
            loginTitleImageView.widthAnchor.constraint(equalToConstant: 240),
        ])
    }
    
    private func configureButton() {
        [bubbleImageView, kakaoButton, naverButton, appleButton/*, testButton*/].forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            
            buttonStackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            kakaoButton.heightAnchor.constraint(equalToConstant: 54),
            naverButton.heightAnchor.constraint(equalToConstant: 54),
            appleButton.heightAnchor.constraint(equalToConstant: 54),
//            testButton.heightAnchor.constraint(equalToConstant: 54),
        ])
        
        buttonStackView.setCustomSpacing(12, after: bubbleImageView)
        
        buttonContainerView.addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor)
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
    
    private func setupLayout() {
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            containerView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
        
        containerView.addSubview(totalStackView)
        totalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            totalStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            totalStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            totalStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            totalStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        spacerView.setContentHuggingPriority(.defaultLow, for: .vertical)
        spacerView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        [titleStackView, spacerView, buttonContainerView].forEach { view in
            totalStackView.addArrangedSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Spacer View 가 먼저 늘고(=여유 흡수), 먼저 줄도록(=작은 화면 보호)
        spacerView.setContentHuggingPriority(.defaultLow, for: .vertical)
        spacerView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        let spacerPreferred = spacerView.heightAnchor.constraint(equalToConstant: 44)
        spacerPreferred.priority = .defaultHigh  // 750
        spacerPreferred.isActive = true

        let spacerMin = spacerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 12)
        spacerMin.priority = .required
        spacerMin.isActive = true
        
        NSLayoutConstraint.activate([
            buttonContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
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
    
    @objc private func presentTerms() {
        let items: [TermsModel] = [
            .init(title: "이용약관 동의",
                  url: URL(string:"https://awesome-captain-026.notion.site/2529598992b080119479fef036d96aba")!,
                  kind: .required,
                  isChecked: false),
            .init(title: "개인정보 처리방침 동의",
                  url: URL(string:"https://awesome-captain-026.notion.site/2529598992b080198821d47baaf7d23f")!,
                  kind: .required,
                  isChecked: false)
        ]

        presentTermsSheet(items: items) { [weak self] updated in
            guard let self = self else { return }
            // (더블체크) 필수 항목 모두 체크되었는지 확인
            let requiredOK = updated
                .filter { $0.kind == .required }
                .allSatisfy { $0.isChecked }
            guard requiredOK else {
                self.presentAlert(title: "안내", message: "필수 약관에 동의해 주세요.")
                return
            }
        }
    }
}
