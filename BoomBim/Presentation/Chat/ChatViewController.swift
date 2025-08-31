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
        pageViewController.view.backgroundColor = .white
        
        return pageViewController
    }()
    
    private let floatingButton: UIButton = {
        let button = UIButton(type: .system)
        
        let image = UIImage.iconAskFloatingButton
        button.setBackgroundImage(image, for: .normal)
        
        return button
    }()
    
    private let refreshRelay = PublishRelay<Void>()
    private let locationRelay = BehaviorRelay<CLLocationCoordinate2D?>(value: nil)
    
    private var voteList: Driver<[VoteItemResponse]>!
    private var myVoteList: Driver<[MyVoteItemResponse]>!
    
    private var voteChatViewController: VoteChatViewController!
    private var questionChatViewController: QuestionChatViewController!
    
    private lazy var pages: [UIViewController] = []
    
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
        
        bindAndSetupPages()
        bindHeaderAction()
        
        setupView()
        
        setLocation()
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
            appear: rx.methodInvoked(#selector(UIViewController.viewDidAppear(_:)))
                .map { _ in () }
                .asSignal(onErrorSignalWith: .empty()),
            refresh: .empty(),
            location: locationRelay
                        .compactMap { $0 }                    // nil 제거
                        .asDriver(onErrorDriveWith: .empty())
                        .do(onNext: { c in print("VM input.location got:", c) })
        )
        
        // VC: 디버그용 구독 (bindAndSetupPages에서 한 번만 붙이세요)
        locationRelay
            .asObservable()
            .subscribe(onNext: { c in print("VC: locationRelay emits ->", c) })
            .disposed(by: disposeBag)

        let output = viewModel.transform(input)
        
        output.isLoading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        output.error
            .emit(onNext: { [weak self] msg in
                self?.presentAlert(title: "오류", message: msg)
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

// MARK: 현재 위치 권한 설정 및 View Rect 값 확인
extension ChatViewController {
    private func setLocation() {
        if locationManager.authorization.value == .notDetermined { // 권한 설정이 안된 경우 권한 요청
//            locationManager.requestWhenInUseAuthorization()
        }
        
        // 권한 상태 스트림에서 '최종 상태(허용/거부)'만 대기 → 1회 처리
        locationManager.authorization
            .asObservable()
            .startWith(locationManager.authorization.value) // 현재 상태 먼저 흘려보내기
            .distinctUntilChanged()
            .filter { status in
                switch status {
                case .authorizedWhenInUse, .authorizedAlways, .denied, .restricted:
                    return true // 최종 상태만 통과
                default:
                    return false // .notDetermined은 대기
                }
            }
            .take(1) // 허용 or 거부 중 첫 결과 한 번만
            .flatMapLatest { [weak self] status -> Observable<CLLocationCoordinate2D> in
                guard let self else { return .empty() }
                switch status {
                case .authorizedWhenInUse, .authorizedAlways:
                    return locationManager.requestOneShotLocation(timeout: 5)
                        .asObservable()
                        .map {
                            print("위도 : \($0.coordinate.latitude), 경도 : \($0.coordinate.longitude)")
                            return $0.coordinate
                        }
                case .denied, .restricted:
                    self.showLocationDeniedAlert()
                    return .empty()
                default:
                    return .empty()
                }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] coord in
                print("coord : \(coord)")
                self?.locationRelay.accept(coord)
            })
            .disposed(by: disposeBag)
    }
    
    /** 위치 접근 안내 Alert */
    private func showLocationDeniedAlert() {
        let alert = UIAlertController(
            title: "위치 접근이 꺼져 있어요",
            message: "현재 위치를 기반으로 검색하려면 설정 > 앱 > 위치에서 허용해 주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
}
