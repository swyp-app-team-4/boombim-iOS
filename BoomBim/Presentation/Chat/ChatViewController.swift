//
//  ChatViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

final class ChatViewController: BaseViewController {
    private let viewModel: ChatViewModel
    private let disposeBag = DisposeBag()
    
    private let locationManager = AppLocationManager.shared
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let headerView = TwoTitleHeaderView()
    private let pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.view.backgroundColor = .background
        
        return pageViewController
    }()
    
    private let floatingButton: UIButton = {
        let button = UIButton(type: .system)
        
        let image = UIImage.iconAskFloatingButton
        button.setBackgroundImage(image, for: .normal)
        
        return button
    }()
    
    private let refreshRelay = PublishRelay<Void>()
    
    private var voteList: Driver<[VoteItemResponse]>!
    private var myVoteList: Driver<[MyVoteItemResponse]>!
    
    private var voteChatViewController: VoteChatViewController!
    private var questionChatViewController: QuestionChatViewController!
    
    private lazy var pages: [UIViewController] = []
    
    private var currentPageIndex: Int = 0

    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        self.title = "소통방"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindAndSetupPages()
        bindHeaderAction()
        
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = . white
        
        configureHeaderView()
        configurePageViewController()
        
        setupFloatingButton()
        
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func configureHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        headerView.setButtonTitle(left: "chat.page.header.vote".localized(), right: "chat.page.header.question".localized())
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configurePageViewController() {
        addChild(pageViewController)
        
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
        
        // ✅ 컨테이너 연결 마무리
        pageViewController.didMove(toParent: self)
    }
    
    private func setupFloatingButton() {
        view.addSubview(floatingButton)
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            floatingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        
        floatingButton.addTarget(self, action: #selector(didTapFloatingButton), for: .touchUpInside)
    }
    
    // MARK: - bind
    private func bindAndSetupPages() {
        let input = ChatViewModel.Input(
            appear: rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:)))
                .map { _ in () }
                .asSignal(onErrorSignalWith: .empty()),
            refresh: refreshRelay.asSignal()
        )

        let output = viewModel.transform(input)
        
        output.isLoading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        output.error
            .emit(onNext: { [weak self] msg in
                self?.presentAlert(title: "오류", message: msg)
            })
            .disposed(by: disposeBag)
        
        output.myCoordinate
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { coord in
                print("내 좌표:", coord)
            })
            .disposed(by: disposeBag)
        
        self.voteList = output.voteList
        self.myVoteList = output.myVoteList
        
        let voteChatViewModel = VoteChatViewModel(items: voteList)
        let questionChatViewModel = QuestionChatViewModel(items: myVoteList)
        
        voteChatViewController = VoteChatViewController(viewModel: voteChatViewModel)
        voteChatViewController.onNeedRefresh = { [weak self] in
            print("cell 변화가 있었으니까 화면 초기화해야됩니다")
            self?.refreshRelay.accept(()) // 부모의 조회 트리거 → 최신 목록 재요청
        }
        
        questionChatViewController = QuestionChatViewController(viewModel: questionChatViewModel)
        
        self.pages = [voteChatViewController, questionChatViewController]
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
    
    @objc private func didTapFloatingButton() {
        viewModel.didTapFloating()
    }
    
    func showPage(_ page: Int, animated: Bool = false) {
        let target = page
        print("target: \(target), current: \(currentPageIndex)")
        guard target != currentPageIndex else { return }
        
        let dir: UIPageViewController.NavigationDirection = target > currentPageIndex ? .forward : .reverse
        currentPageIndex = target
        headerView.updateSelection(index: target, animated: true)
        pageViewController.setViewControllers([pages[target]], direction: dir, animated: animated)
    }
}

extension ChatViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
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
