//
//  LoginViewController.swift
//  SwypTeam4
//
//  Created by 조영현 on 8/1/25.
//

import UIKit
import RxSwift
import NidThirdPartyLogin

final class LoginViewController: UIViewController {
    private let viewModel = LoginViewModel()
    private let disposeBag = DisposeBag()

    private let kakaoButton = KakaoLoginButton()
    private let naverButton = NaverLoginButton()
    private let appleButton = UIButton()

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
        [kakaoButton, naverButton].forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(button)
        }
        
        NSLayoutConstraint.activate([
            kakaoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            kakaoButton.bottomAnchor.constraint(equalTo: naverButton.topAnchor, constant: -20),
//            kakaoButton.widthAnchor.constraint(equalToConstant: 300),
//            kakaoButton.heightAnchor.constraint(equalToConstant: 45),
            
            naverButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            naverButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
//            naverButton.widthAnchor.constraint(equalToConstant: 300),
//            naverButton.heightAnchor.constraint(equalToConstant: 45)
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
                    print("로그인 성공: \(token)")
                    // 백엔드에 token 전달
                case .failure(let error):
                    print("로그인 실패: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
}
