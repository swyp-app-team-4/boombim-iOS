//
//  HomeViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit

final class HomeViewController: UIViewController {
    private let viewModel: HomeViewModel
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<HomeSection, HomeItem>!
    
    // Page control for Region section
    private let pageControl = UIPageControl()
    private var regionCount: Int = 0 {
        didSet { pageControl.numberOfPages = regionCount }
    }
    private var regionCurrentPage: Int = 0 {
        didSet { pageControl.currentPage = regionCurrentPage }
    }
    
    private var autoScrollTimer: Timer?
    private var isUserDraggingRegion = false
    
    private let floatingButton: UIButton = {
        let button = UIButton(type: .system)
        
        let image = UIImage.iconFloatingButton
        button.setBackgroundImage(image, for: .normal)
        
        return button
    }()
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "홈"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupView()
    }
    
    // MARK: Setup UI
    private func setupNavigationBar() {
        title = "홈"
        
        let searchButton = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .plain,
            target: self,
            action: #selector(didTapSearchButton)
        )
        
        let notificationButton = UIBarButtonItem(
            image: UIImage(systemName: "bell"),
            style: .plain,
            target: self,
            action: #selector(didTapNotificationButton)
        )
        
        navigationItem.rightBarButtonItems = [notificationButton, searchButton]
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        configureCollectionView()
        configureDataSource()
        configurePageControl()
        
        setupFloatingButton()
        
        applyInitialSnapshot() // dummy Data
        
        startAutoScroll()
    }
    
    // MARK: Setup UI
    private func setupFloatingButton() {
        view.addSubview(floatingButton)
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            floatingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        
        floatingButton.addTarget(self, action: #selector(didTapFloatingButton), for: .touchUpInside)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configurePageControl() {
        pageControl.hidesForSinglePage = true
        pageControl.isUserInteractionEnabled = false
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: DataSource
    private func configureDataSource() {
        let regionRegistration = UICollectionView.CellRegistration<RegionCardCell, RegionItem> { cell, _, item in
            cell.configure(item)
        }
        let imageTextRegistration = UICollectionView.CellRegistration<ImageTextCell, ImageTextItem> { cell, _, item in
            cell.configure(item)
        }
        let placeRegistration = UICollectionView.CellRegistration<PlaceCell, PlaceItem> { cell, _, item in
            cell.configure(item)
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<TitleHeaderView>(elementKind: TitleHeaderView.elementKind) { [weak self] header, _, indexPath in
            guard let section = HomeSection(rawValue: indexPath.section) else { return }
            if let title = section.headerTitle {
                header.configure(title)
            }
            // Region section controls page control visibility
            self?.pageControl.isHidden = (section != .region)
        }
        
        dataSource = UICollectionViewDiffableDataSource<HomeSection, HomeItem>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .region(let m):
                return collectionView.dequeueConfiguredReusableCell(using: regionRegistration, for: indexPath, item: m)
            case .imageText(let m):
                return collectionView.dequeueConfiguredReusableCell(using: imageTextRegistration, for: indexPath, item: m)
            case .place(let m):
                return collectionView.dequeueConfiguredReusableCell(using: placeRegistration, for: indexPath, item: m)
            }
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == TitleHeaderView.elementKind else { return nil }
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }
    
    private func applyInitialSnapshot() {
        // TODO: Replace with ViewModel outputs
        let regions: [RegionItem] = [
            .init(title: "강남구", subtitle: "현재 혼잡도: 보통", iconName: "mappin.and.ellipse"),
            .init(title: "홍대입구", subtitle: "현재 혼잡도: 높음", iconName: "mappin"),
            .init(title: "잠실", subtitle: "현재 혼잡도: 낮음", iconName: "location"),
        ]
        regionCount = regions.count
        
        let imageTexts: [ImageTextItem] = [
            .init(imageName: "sample1", title: "주말 축제 소식"),
            .init(imageName: "sample2", title: "인기 스팟 모아보기"),
            .init(imageName: "sample3", title: "야간 카페 추천"),
        ]
        
        let favorites: [PlaceItem] = [
            .init(name: "선릉 카페", detail: "450m · 테라스", congestion: "여유"),
            .init(name: "역삼 맛집", detail: "1.2km · 웨이팅", congestion: "보통")
        ]
        
        let crowded: [PlaceItem] = [
            .init(name: "코엑스", detail: "2.1km · 행사 중", congestion: "혼잡"),
            .init(name: "롯데월드", detail: "6.4km · 주말 피크", congestion: "매우 혼잡")
        ]
        
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeItem>()
        snapshot.appendSections(HomeSection.allCases)
        snapshot.appendItems(regions.map { .region($0) }, toSection: .region)
        snapshot.appendItems(imageTexts.map { .imageText($0) }, toSection: .imageText)
        snapshot.appendItems(favorites.map { .place($0) }, toSection: .favorites)
        snapshot.appendItems(crowded.map { .place($0) }, toSection: .crowded)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: Layout
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, env -> NSCollectionLayoutSection? in
            guard let sectionKind = HomeSection(rawValue: sectionIndex) else { return nil }
            switch sectionKind {
            case .region:
                return Self.makeRegionSection(env: env, pageUpdate: { [weak self] page in
                    self?.regionCurrentPage = page
                })
            case .imageText:
                return Self.makeImageTextSection(env: env)
            case .favorites, .crowded:
                return Self.makeListSection(env: env, hasHeader: true)
            }
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 16
        layout.configuration = config
        return layout
    }
    
    private static func makeRegionSection(env: NSCollectionLayoutEnvironment, pageUpdate: @escaping (Int) -> Void) -> NSCollectionLayoutSection {
        // Item is card width ~90% of container
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.90), heightDimension: .absolute(180))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20)
        
        // Page detection via invalidation handler
        section.visibleItemsInvalidationHandler = { items, offset, env in
            guard let width = env.container.effectiveContentSize.width as CGFloat?, width > 0 else { return }
            // When centered paging, current page approx:
            let page = Int(round(offset.x / width))
            pageUpdate(max(page, 0))
        }
        return section
    }
    
    private static func makeImageTextSection(env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(180), heightDimension: .estimated(170))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(180), heightDimension: .estimated(170))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20)
        return section
    }
    
    private static func makeListSection(env: NSCollectionLayoutEnvironment, hasHeader: Bool) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(56))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(56))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(8)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 16, trailing: 20)
        
        if hasHeader {
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(34))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: TitleHeaderView.elementKind, alignment: .top)
            section.boundarySupplementaryItems = [header]
        }
        return section
    }
    
    // MARK: Auto scroll for region
    private func startAutoScroll() {
        stopAutoScroll()
        guard regionCount > 1 else { return }
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self, !self.isUserDraggingRegion else { return }
            let next = (self.regionCurrentPage + 1) % max(self.regionCount, 1)
            let indexPath = IndexPath(item: next, section: HomeSection.region.rawValue)
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.regionCurrentPage = next
        }
    }
    
    private func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    // MARK: Action
    @objc private func didTapFloatingButton() {
        viewModel.goToCongestionReportView?()
    }
    
    @objc private func didTapSearchButton() {
        viewModel.didTapSearch()
    }
    
    @objc private func didTapNotificationButton() {
        viewModel.didTapNotification()
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Only care when dragging in Region section area
        // Rough check: pageControl is only visible for region
        if !pageControl.isHidden { isUserDraggingRegion = true }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isUserDraggingRegion = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { isUserDraggingRegion = false }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .place(let place):
            viewModel.didSelectPlace(place)
        default:
            break
        }
    }
}
