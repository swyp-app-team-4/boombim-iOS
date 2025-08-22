//
//  ChatViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit

final class ChatViewController: UIViewController {
    private let viewModel: ChatViewModel
    
    private let headerView = TwoTitleHeaderView()
    private let pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.view.backgroundColor = .white
        
        return pageViewController
    }()
    
    private lazy var pages: [UIViewController] = [NewsViewController(), NoticeViewController()]
    
    private var currentPageIndex: Int = 0

    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "소통"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}
