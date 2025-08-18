//
//  NicknameViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/18/25.
//

import UIKit

final class NicknameViewController: UIViewController {
    private let viewModel: NicknameViewModel

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
        view.backgroundColor = .systemBackground
    }
}
