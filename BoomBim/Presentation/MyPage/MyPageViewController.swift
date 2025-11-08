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
    
    private let pointContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .grayScale1
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.shadow.cgColor
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 4
        
        return view
    }()
    
    private let pointStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    
    private let pointLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.setPoints(0, numberStyle: Typography.Body02.semiBold, numberColor: .main)
        
        return label
    }()
    
    private let pointButton: UIButton = {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.plain()
        // 제목
        var attr = AttributeContainer()
        attr.font = Typography.Body03.medium.font
        config.attributedTitle = AttributedString("포인트 내역", attributes: attr)
        
        // 아이콘
        config.image = .iconRightArrow
        config.imagePlacement = .trailing   // ← 오른쪽으로
        config.imagePadding = 6            // 텍스트와 간격
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        // 색상
        config.baseForegroundColor = .grayScale8
        
        button.configuration = config
        return button
    }()
    
    private let headerView = MyHeaderView()
    private let pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.view.backgroundColor = .background
        
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
        
        setProfile()
        setPointAction()
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
        view.backgroundColor = .background
        
        configureProfileView()
        configurePointView()
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
    
    private func configurePointView() {
        [pointLabel, pointButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            pointStackView.addArrangedSubview($0)
        }
        
        pointStackView.translatesAutoresizingMaskIntoConstraints = false
        pointContainerView.addSubview(pointStackView)
        
        pointContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pointContainerView)
        
        NSLayoutConstraint.activate([
            pointStackView.topAnchor.constraint(equalTo: pointContainerView.topAnchor, constant: 10),
            pointStackView.bottomAnchor.constraint(equalTo: pointContainerView.bottomAnchor, constant: -10),
            pointStackView.leadingAnchor.constraint(equalTo: pointContainerView.leadingAnchor, constant: 14),
            pointStackView.trailingAnchor.constraint(equalTo: pointContainerView.trailingAnchor, constant: -14),
            
            pointContainerView.topAnchor.constraint(equalTo: profileView.bottomAnchor, constant: 14),
            pointContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pointContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func configureHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: pointContainerView.bottomAnchor, constant: 18),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configurePageViewController() {
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
        profileView.configure(name: "닉네임", profile: nil)
        profileView.onTapEdit = { [weak self] in
            self?.viewModel.didTapProfile()
        }
    }
    
    private func setPoint(point: Int) {
        pointLabel.setPoints(point, numberStyle: Typography.Body02.semiBold, numberColor: .main)
    }
    
    // MARK: Action
    @objc private func didTapSettingsButton() {
        viewModel.didTapSettings()
    }
    
    private func setPointAction() {
        pointButton.addTarget(self, action: #selector(didTapPointButton), for: .touchUpInside)
    }
    
    @objc private func didTapPointButton() {
        viewModel.didTapPoint()
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
                    profile: p.profile)
            })
            .disposed(by: disposeBag)
        
        output.point
            .drive(onNext: { [weak self] p in
                guard let self else { return }
                
                setPoint(point: p.point)
            })
            .disposed(by: disposeBag)
        
        let favoriteViewModel = FavoriteViewModel(items: output.favorite)
        let favoriteViewController = FavoriteViewController(viewModel: favoriteViewModel)
        
        let historyViewModel = HistoryViewModel(items: output.history)
        let historyViewController = HistoryViewController(viewModel: historyViewModel)
        
//        let voteViewModel = VoteViewModel(items: output.answer)
//        let voteViewController = VoteViewController(viewModel: voteViewModel)
//        
//        let questionViewModel = QuestionViewModel(items: output.question)
//        let questionViewController = QuestionViewController(viewModel: questionViewModel)
        
        /// 1.0.1 version 적용 내역) 투표와 질문이 사라짐.
        self.pages = [favoriteViewController, historyViewController]
        
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

