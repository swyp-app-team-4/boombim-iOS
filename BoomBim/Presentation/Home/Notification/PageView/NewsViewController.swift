//
//  NewsViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/20/25.
//

import UIKit

final class NewsViewController: UIViewController {
    
    private let emptyStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 16
        
        return stackView
    }()
    
    private let emptyIllustrationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .illustrationNotification
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.medium.font
        label.textColor = .grayScale10
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "notification.empty.label".localized()
        
        return label
    }()
    
    private lazy var emptyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .main
        button.setTitle("norification.empty.button".localized(), for: .normal)
        button.setTitleColor(.grayScale1, for: .normal)
        button.titleLabel?.font = Typography.Body02.medium.font
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupActions()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        configureEmptyStackView()
    }
    
    private func configureEmptyStackView() {
        [emptyIllustrationImageView, emptyTitleLabel, emptyButton].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            emptyStackView.addArrangedSubview(view)
        }
        
        emptyStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStackView)
        
        NSLayoutConstraint.activate([
            emptyButton.heightAnchor.constraint(equalToConstant: 44),
            
            emptyStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            emptyStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupActions() {
        setupEmptyButtonAction()
    }
    
    private func setupEmptyButtonAction() {
        emptyButton.addTarget(self, action: #selector(emptyButtonTapped), for: .touchUpInside)
    }
    
    @objc private func emptyButtonTapped() {
        print("empty Button Tapped")
    }
}
