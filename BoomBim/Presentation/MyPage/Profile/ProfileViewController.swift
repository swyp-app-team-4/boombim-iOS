//
//  ProfileViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/11/25.
//

import UIKit

final class ProfileViewController: BaseViewController {
    private let viewModel: ProfileViewModel
    
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "프로필"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}
