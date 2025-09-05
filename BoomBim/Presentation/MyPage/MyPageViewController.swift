//
//  MyPageViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit
import RxSwift

final class MyPageViewController: BaseViewController {
    private let viewModel: MyPageViewModel
    private let disposeBag = DisposeBag()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let profileView = MyProfileView()
    private let headerView = MyHeaderView()
    private let pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.view.backgroundColor = .white
        
        return pageViewController
    }()
    
    private lazy var pages: [UIViewController] = []
    
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
        
        bind()
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
//        pageViewController.setViewControllers([pages[currentPageIndex]], direction: .forward, animated: false, completion: nil)
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
        profileView.configure(name: "닉네임", profile: nil, email: "123", socialProvider: "dfd", vote: 0, question: 0)
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
    
    // MARK: - bind
    private func bind() {
        // 1) Input: 화면 등장 시점 (원하면 .take(1)로 최초 1회만)
        let appear = rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:)))
            .map { _ in () }
            .asSignal(onErrorSignalWith: .empty())
        
        let input = MyPageViewModel.Input(appear: appear)
        let output = viewModel.transform(input)
        
        // 2) 로딩 인디케이터 + 입력 비활성화
        output.isLoading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        // 3) 에러 알림
        output.error
            .emit(onNext: { [weak self] msg in
                self?.presentAlert(title: "오류", message: msg)
            })
            .disposed(by: disposeBag)
        
        // 4) 프로필 UI 바인딩 (Nuke로 이미지 로딩)
        output.profile
            .drive(onNext: { [weak self] p in
                guard let self else { return }
                
                self.profileView.configure(
                    name: p.name,
                    profile: p.profile,
                    email: p.email,
                    socialProvider: p.socialProvider,
                    vote: p.voteCnt,
                    question: p.questionCnt)
            })
            .disposed(by: disposeBag)
        
        let voteViewModel = VoteViewModel(items: output.answer)
        let voteViewController = VoteViewController(viewModel: voteViewModel)
        
        let questionViewModel = QuestionViewModel(items: output.question)
        let questionViewController = QuestionViewController(viewModel: questionViewModel)
        
        self.pages = [FavoriteViewController(), voteViewController, questionViewController]
        
        // 현재 인덱스가 범위를 벗어나지 않게 보정
        self.currentPageIndex = min(self.currentPageIndex, max(self.pages.count - 1, 0))
        
        self.pageViewController.setViewControllers([self.pages[self.currentPageIndex]], direction: .forward, animated: false, completion: nil)
        // 헤더도 동기화
        self.headerView.updateSelection(index: self.currentPageIndex, animated: false)
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
