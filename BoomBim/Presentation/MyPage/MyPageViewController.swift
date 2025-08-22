//
//  MyPageViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit

final class MyPageViewController: BaseViewController {
    private let viewModel: MyPageViewModel
    
    private let profileView = MyProfileView()
    private let headerView = MyHeaderView()
    private let pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.view.backgroundColor = .white
        
        return pageViewController
    }()
    
    private lazy var pages: [UIViewController] = [FavoriteViewController(), VoteViewController(), QuestionViewController()]
    
    private var currentPageIndex: Int = 0

    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        self.title = "마이페이지"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupView()
        
        bindHeaderAction()
        
        // dummy data
        setProfile()
    }
    
    // MARK: Setup UI
    private func setupNavigationBar() {
        
        let settingsButton = UIBarButtonItem(
            image: .iconSetting,
            style: .plain,
            target: self,
            action: #selector(didTapSettingsButton)
        )
        settingsButton.tintColor = .grayScale9
        
        navigationItem.rightBarButtonItems = [settingsButton]
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        configureProfileView()
        configureHeaderView()
        configurePageViewController()
    }
    
    private func configureProfileView() {
        profileView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileView)
        
        NSLayoutConstraint.activate([
            profileView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            profileView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileView.heightAnchor.constraint(equalToConstant: 74)
        ])
    }
    
    private func configureHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: profileView.bottomAnchor, constant: 18),
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
    
    private func setProfile() {
        profileView.configure(name: "조영현", vote: "5", question: "10")
    }
    
    // MARK: Action
    @objc private func didTapSettingsButton() {
        viewModel.didTapSettings()
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

extension MyPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let idx = pages.firstIndex(of: viewController), idx > 0 else { return nil }
        return pages[idx - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let idx = pages.firstIndex(of: viewController), idx < pages.count - 1 else { return nil }
        return pages[idx + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let vc = pageViewController.viewControllers?.first,
              let idx = pages.firstIndex(of: vc) else { return }
        
        currentPageIndex = idx
        headerView.updateSelection(index: idx, animated: true)
    }
}
