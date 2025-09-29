//
//  OnboardingPageViewController.swift
//  BoomBim
//
//  Created by 조영현 on 9/3/25.
//

import UIKit

final class OnboardingPageViewController: UIViewController {
    
    private let titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 6
        
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayScale10
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayScale8
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    init(title: String, subTitle: String?, image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        
        titleLabel.setText(title, style: Typography.Heading01.semiBold)
        
        if let sub = subTitle, !sub.isEmpty {
            subTitleLabel.setText(sub, style: Typography.Body02.regular)
            subTitleLabel.isHidden = false
        } else {
            subTitleLabel.isHidden = true
        }
        
        self.imageView.image = image
    }
    
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .grayScale1
        
        configureText()
        configureImageView()
    }
    
    private func configureText() {
        [titleLabel, subTitleLabel].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            titleStackView.addArrangedSubview(label)
        }
        
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleStackView)
        
        NSLayoutConstraint.activate([
            titleStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            titleStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func configureImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 6),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
}
