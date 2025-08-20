//
//  NotificationViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/8/25.
//

import UIKit

final class NotificationViewController: BaseViewController {
    private let viewModel: NotificationViewModel
    
    init(viewModel: NotificationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    private func setupView() {
        
    }
    
    private func setupNavigationBar() {
        title = ""
        
        
    }
}
