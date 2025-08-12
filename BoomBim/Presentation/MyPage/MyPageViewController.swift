//
//  MyPageViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit

final class MyPageViewController: UIViewController {
    private let viewModel: MyPageViewModel
    
    private let profileView = ProfileHeaderView()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        
        return stackView
    }()

    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupView()
    }
    
    // MARK: Setup UI
    private func setupNavigationBar() {
        title = "마이페이지"
        
        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(didTapSettingsButton)
        )
        
        navigationItem.rightBarButtonItems = [settingsButton]
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(profileView)
        
        profileView.editButton.addTarget(self, action: #selector(didTapProfileButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
    }

    
    // MARK: Action
    @objc private func didTapSettingsButton() {
        viewModel.didTapSettings()
    }
    
    @objc private func didTapProfileButton() {
        viewModel.didTapProfile()
    }
}
