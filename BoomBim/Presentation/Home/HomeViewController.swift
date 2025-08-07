//
//  HomeViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit

final class HomeViewController: UIViewController {
    private let viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "홈"
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
        title = "홈"

        let searchButton = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .plain,
            target: self,
            action: #selector(didTapSearchButton)
        )
        
        navigationItem.rightBarButtonItem = searchButton
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
    }

    // MARK: Action
    @objc private func didTapSearchButton() {
        viewModel.didTapSearch()
    }}
