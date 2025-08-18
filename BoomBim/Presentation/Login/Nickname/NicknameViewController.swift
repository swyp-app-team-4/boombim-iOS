//
//  NicknameViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/18/25.
//

import UIKit

final class NicknameViewController: UIViewController {
    private let viewModel: NicknameViewModel
    
    // MARK: - UI
    private let nicknameTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.grayScale9
        label.font = Typography.Heading01.semiBold.font
        label.textAlignment = .left
        label.numberOfLines = 1
        label.text = "nickname.label.title.main".localized()
        
        return label
    }()
    
    private let nicknameSubTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.grayScale8
        label.font = Typography.Caption.regular.font
        label.textAlignment = .left
        label.numberOfLines = 1
        label.text = "nickname.label.title.sub".localized()
        
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.iconEmptyProfile
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let addProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage.iconCamera, for: .normal)
        
        return button
    }()
    
    private let textFieldTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.grayScale8
        label.font = Typography.Body03.regular.font
        label.textAlignment = .left
        label.numberOfLines = 1
        label.text = "nickname.label.nickname".localized()
        
        return label
    }()
    
    private let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.layer.cornerRadius = 6
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.grayScale4.cgColor
        
        textField.textColor = .grayScale8
        textField.font = Typography.Body03.regular.font
        textField.placeholder = "nickname.textfield.placeholder".localized()
        
        return textField
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.grayScale4
        button.setTitle( "nickname.button.signup".localized(), for: .normal)
        button.setTitleColor(.grayScale7, for: .normal)
        button.titleLabel?.font = Typography.Body02.medium.font
        
        return button
    }()

    init(viewModel: NicknameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "닉네임 설정"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTextFieldActions()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        configureTitle()
        configureImageView()
        configureTextField()
        configureButton()
    }
    
    private func configureTitle() {
        [nicknameTitleLabel, nicknameSubTitleLabel].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
        }
        
        NSLayoutConstraint.activate([
            nicknameTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            nicknameTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nicknameTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            nicknameSubTitleLabel.topAnchor.constraint(equalTo: nicknameTitleLabel.bottomAnchor, constant: 4),
            nicknameSubTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nicknameSubTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func configureImageView() {
        [profileImageView, addProfileButton].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: nicknameSubTitleLabel.bottomAnchor, constant: 28),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addProfileButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -2),
            addProfileButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 9),
        ])
    }
    
    private func configureTextField() {
        [textFieldTitleLabel, nicknameTextField].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            textFieldTitleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 32),
            textFieldTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            nicknameTextField.topAnchor.constraint(equalTo: textFieldTitleLabel.bottomAnchor, constant: 4),
            nicknameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nicknameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func configureButton() {
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signUpButton)
        
        NSLayoutConstraint.activate([
            signUpButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    // MARK: - Action
    private func setupTextFieldActions() {
        nicknameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            textField.layer.borderWidth = 1   // 두꺼워짐
            textField.layer.borderColor = UIColor.grayScale7.cgColor
        } else {
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor.grayScale4.cgColor
        }
    }
}
