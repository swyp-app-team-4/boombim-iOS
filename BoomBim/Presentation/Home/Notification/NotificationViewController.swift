//
//  NotificationViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/8/25.
//

import UIKit
import RxSwift
import RxCocoa
import GoogleMobileAds

final class NotificationViewController: BaseViewController {
    private let viewModel: NotificationViewModel
    private let disposeBag = DisposeBag()
    
    private let headerView = TwoTitleHeaderView()
    private let pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.view.backgroundColor = .white
        
        return pageViewController
    }()
    
    private lazy var newsVC = NewsViewController()
    private lazy var noticeVC = NoticeViewController()
    private lazy var pages: [UIViewController] = [newsVC, noticeVC]
    
    private var currentPageIndex: Int = 0
    
    private let bannerContainer = UIView()
    private var bannerView: BannerView?
    
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
        setupBanner()
        
        bind()
        
        bindHeaderAction()
    }
    
    private func setupView() {
        view.backgroundColor = .background
        
        configureHeaderView()
        configureBanner()
        configurePageViewController()
    }
    
    private func setupNavigationBar() {
        self.title = "알림"
        
        // TODO: navigation 또는 modal의 차이에 따라서 달라질 예정
        navigationController?.navigationBar.tintColor = .grayScale9
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    private func configureHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        headerView.setButtonTitle(left: "notification.page.header.news".localized(), right: "notification.page.header.notice".localized())
        
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
//            pageViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            pageViewController.view.bottomAnchor.constraint(equalTo: bannerContainer.topAnchor)
        ])
    }
    
    private func configureBanner() {
        bannerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerContainer)
        
        NSLayoutConstraint.activate([
            bannerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupBanner() {
        // 1) 현재 화면 폭 기준으로 Anchored Adaptive 사이즈 계산
        let viewWidth = view.bounds.inset(by: view.safeAreaInsets).width
        let adSize = currentOrientationAnchoredAdaptiveBanner(width: viewWidth) // iOS 권장 배너
        
        // 2) 배너 생성 및 루트 설정
        let banner = BannerView(adSize: adSize)
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.adUnitID = "ca-app-pub-1220293492029262/8295983520"
        banner.rootViewController = self
        
        bannerContainer.addSubview(banner)
        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: bannerContainer.centerXAnchor),
            banner.topAnchor.constraint(equalTo: bannerContainer.topAnchor),
            banner.bottomAnchor.constraint(equalTo: bannerContainer.bottomAnchor),
            banner.widthAnchor.constraint(equalToConstant: adSize.size.width),
            banner.heightAnchor.constraint(equalToConstant: adSize.size.height)
        ])
        self.bannerView = banner
        
        // 3) 로드
        banner.load(Request())
    }
    
    // MARK: - bind
    private func bind() {
        viewModel.tokenResult
            .subscribe(onNext: { result in
                switch result {
                case .success(let response):
                    print("viewModel.tokenResult: \(response)")
//                    TokenManager.shared.fcmTokenUploadState = true
                    self.viewModel.fetchAlarm()
                case .failure(let error):
                    print("Error register token: \(error)")
                }
            })
            .disposed(by: disposeBag)

        
        viewModel.alarmResult
            .subscribe(onNext: { result in
                switch result {
                case .success(let response):
                    print("Fetched alarm: \(response)")
                    let items: [NoticeItem] = response.map(Self.makeNoticeItem(_:))
                    self.noticeVC.apply(notices: items)
                case .failure(let error):
                    print("Error fetching alarm: \(error)")
                    self.noticeVC.apply(notices: []) // 비우거나 유지
                }
            })
            .disposed(by: disposeBag)
        
        guard let fcmTokenUploadState = TokenManager.shared.fcmTokenUploadState else { return }
        if fcmTokenUploadState {
            viewModel.fetchAlarm()
        } else {
            viewModel.setFcmToken()
        }
    }
    
    private static func makeNoticeItem(_ dto: AlarmItem) -> NoticeItem {
        return NoticeItem(
            image: .illustrationNotification,         // 필요 시 URL/이미지 매핑
            title: dto.title,
            date: dto.alarmTime,                // 포맷팅
            isRead: false // dto.deliveryStatus
        )
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
