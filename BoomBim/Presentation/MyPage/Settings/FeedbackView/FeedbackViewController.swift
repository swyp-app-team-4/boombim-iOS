//
//  FeedbackViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/28/25.
//

import UIKit
import RxSwift
import RxCocoa

final class FeedbackViewController: BaseViewController {
    private let viewModel: FeedbackViewModel
    private let disposeBag = DisposeBag()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .white
        textView.font = Typography.Body03.medium.font
        textView.textColor = .black
        textView.isScrollEnabled = false
        
        return textView
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("chat.button.next".localized(), for: .normal)
        button.titleLabel?.font = Typography.Body02.medium.font
        button.setTitleColor(.grayScale7, for: .normal)
        button.backgroundColor = .grayScale4
//        button.setTitleColor(.grayScale1, for: .normal)
//        button.backgroundColor = .main
        button.layer.cornerRadius = 10
        button.isEnabled = false
        
        return button
    }()
    
    init(viewModel: FeedbackViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bind()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        [textView, button].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.heightAnchor.constraint(equalToConstant: 300),
            
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func bind() {
        // 버튼 활성화 (간단 검증)
        textView.rx.text.orEmpty
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 }
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 제출
        button.rx.tap
            .asSignal() // tap을 Signal로
            .withLatestFrom(
                textView.rx.text.orEmpty
                    .asObservable()                           // Driver(ControlProperty) → Observable
                    .asSignal(onErrorSignalWith: .empty())    // Observable → Signal
            )
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .emit(onNext: { [weak self] reason in
                self?.viewModel.onSubmit?(reason)
            })
            .disposed(by: disposeBag)
    }
}
