//
//  NotificationViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/8/25.
//

import UIKit

final class NotificationViewController: BaseViewController {
    private let viewModel: NotificationViewModel
    
    private let headerView = NotificationHeaderView()
    private let pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.view.backgroundColor = .white
        
        return pageViewController
    }()
    
    private lazy var pages: [UIViewController] = [NewsViewController(), NoticeViewController()]
    
    private var currentPageIndex: Int = 0
    
    init(viewModel: NotificationViewModel) {
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
        
        bindHeaderAction()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        configureHeaderView()
        configurePageViewController()
    }
    
    private func setupNavigationBar() {
        title = "알림"
        
        // TODO: navigation 또는 modal의 차이에 따라서 달라질 예정
    }
    
    private func configureHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configurePageViewController() {
        pageViewController.setViewControllers([pages[currentPageIndex]], direction: .forward, animated: false, completion: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageViewController.view)
        
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - bind Action
    private func bindHeaderAction() {
        headerView.backgroundColor = .clear
        headerView.onSelectIndex = { [weak self] toIndex in
            guard let self, toIndex != self.currentPageIndex, (0..<self.pages.count).contains(toIndex) else { return }
            
            let direction: UIPageViewController.NavigationDirection = (toIndex > self.currentPageIndex) ? .forward : .reverse
            self.pageViewController.setViewControllers([self.pages[toIndex]], direction: direction, animated: true)
            
            self.currentPageIndex = toIndex
            self.headerView.updateSelection(index: toIndex, animated: true)
        }
    }
}

extension NotificationViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let idx = pages.firstIndex(of: viewController), idx > 0 else { return nil }
        return pages[idx - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let idx = pages.firstIndex(of: viewController), idx < pages.count - 1 else { return nil }
        return pages[idx + 1]
    }
    
    // 스와이프 완료 시 헤더 상태 동기화
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let vc = pageViewController.viewControllers?.first,
              let idx = pages.firstIndex(of: vc) else { return }
        
        currentPageIndex = idx
        headerView.updateSelection(index: idx, animated: true)
    }
}
