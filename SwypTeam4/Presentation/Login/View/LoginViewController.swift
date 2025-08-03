//
//  LoginViewController.swift
//  SwypTeam4
//
//  Created by 조영현 on 8/1/25.
//

import UIKit
import RxSwift

final class LoginViewController: UIViewController {
    private let viewModel = LoginViewModel()
    private let disposeBag = DisposeBag()

    // 버튼들
    private let kakaoButton = KakaoLoginButton()
    private let naverButton = UIButton()
    private let appleButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("loginViewcontroller")
        
        setupUI()
        bind()
    }
    
    private func setupUI() {
        view.addSubview(kakaoButton)

        kakaoButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            kakaoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            kakaoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            kakaoButton.widthAnchor.constraint(equalToConstant: 300),
            kakaoButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    private func bind() {
        let input = LoginViewModel.Input(
            kakaoTap: kakaoButton.rx.tap.asObservable(),
            naverTap: naverButton.rx.tap.asObservable(),
            appleTap: appleButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.loginResult
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { result in
                switch result {
                case .success(let token):
                    print("🎉 로그인 성공: \(token)")
                    // 👉 백엔드에 token 전달 후 JWT 저장
                case .failure(let error):
                    print("❌ 로그인 실패: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
}
