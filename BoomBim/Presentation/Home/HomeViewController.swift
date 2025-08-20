//
//  HomeViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit

final class HomeViewController: BaseViewController {
    private let viewModel: HomeViewModel
    
    private var dataSource: UICollectionViewDiffableDataSource<HomeSection, HomeItem>!
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .white
        collectionView.directionalLayoutMargins = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        collectionView.contentInset.top = 22 // 최상단 간격
        
        return collectionView
    }()
    
    private let floatingButton: UIButton = {
        let button = UIButton(type: .system)
        
        let image = UIImage.iconFloatingButton
        button.setBackgroundImage(image, for: .normal)
        
        return button
    }()
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    // MARK: Setup UI
    private func setupView() {
        view.backgroundColor = .white
        
        setupNavigationBar()
        
        configureCollectionView()
        configureDataSource()
        
        setupFloatingButton()
        
        applyInitialSnapshot() // dummy Data
    }
    
    private func setupNavigationBar() {
        let logoImageView = UIImageView(image: .logoText)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let logoItem = UIBarButtonItem(customView: logoImageView)
        navigationItem.leftBarButtonItem = logoItem
        
        let searchButton = UIBarButtonItem(
            image: .iconSearch,
            style: .plain,
            target: self,
            action: #selector(didTapSearchButton)
        )
        searchButton.tintColor = .grayScale9
        
        let notificationButton = UIBarButtonItem(
            image: .iconAlarm,
            style: .plain,
            target: self,
            action: #selector(didTapNotificationButton)
        )
        notificationButton.tintColor = .grayScale9
        
        navigationItem.rightBarButtonItems = [searchButton, notificationButton]
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
    
    private func configureCollectionView() {
        
        collectionView.delegate = self
        collectionView.register(RegionCardCell.self, forCellWithReuseIdentifier: RegionCardCell.identifier)
        collectionView.register(SeparatorView.self, forSupplementaryViewOfKind: SeparatorView.elementKind, withReuseIdentifier: SeparatorView.identifier)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: DataSource
    private func configureDataSource() {
        // section 별 구성
        let regionRegistration = UICollectionView.CellRegistration<RegionCardCell, [RegionItem]> { cell, _, item in
            cell.configure(items: item)
        }
        
        let recommendRegistration = UICollectionView.CellRegistration<RecommendPlaceCell, RecommendPlaceItem> { cell, _, item in
            cell.configure(item)
        }
        
        let favoriteRegistration = UICollectionView.CellRegistration<FavoriteCell, FavoritePlaceItem> { cell, _, item in
            cell.configure(item)
        }
        
        let congestionRankRegistration = UICollectionView.CellRegistration<CongestionRankCell, CongestionRankPlaceItem> { cell, _, item in
            cell.configure(item)
        }
        
        // Header 설정
        let headerRegistration = UICollectionView.SupplementaryRegistration<TitleHeaderView>(elementKind: TitleHeaderView.elementKind) { [weak self] header, _, indexPath in
            guard let section = HomeSection(rawValue: indexPath.section) else { return }
            let title = section.headerTitle
            let image = section.headerImage
            let showsButton = section.headerButton
            
            header.configure(text: title ?? "", image: image, button: showsButton, buttonHandler: {
                print("button Action")
            })
        }
        
        let separatorRegistration = UICollectionView.SupplementaryRegistration<SeparatorView>(elementKind: SeparatorView.elementKind) { separator, _, indexPath in
            guard let section = HomeSection(rawValue: indexPath.section) else { return }
            
            separator.configure()
        }
        
        dataSource = UICollectionViewDiffableDataSource<HomeSection, HomeItem>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .region(let m):
                return collectionView.dequeueConfiguredReusableCell(using: regionRegistration, for: indexPath, item: m)
            case .recommendPlace(let m):
                return collectionView.dequeueConfiguredReusableCell(using: recommendRegistration, for: indexPath, item: m)
            case .favoritePlace(let m):
                return collectionView.dequeueConfiguredReusableCell(using: favoriteRegistration, for: indexPath, item: m)
            case .congestionRank(let m):
                return collectionView.dequeueConfiguredReusableCell(using: congestionRankRegistration, for: indexPath, item: m)
            }
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self else { return nil }
            
            switch kind {
            case TitleHeaderView.elementKind:
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
                
            case SeparatorView.elementKind:
                guard let section = HomeSection(rawValue: indexPath.section) else { return nil}
                
                let view = collectionView.dequeueConfiguredReusableSupplementary(using: separatorRegistration, for: indexPath)
                
                let count = self.dataSource.snapshot().numberOfItems(inSection: section)
                view.isHidden = (indexPath.item == count - 1) // 마지막 셀이라면 숨김
                
                return view
                
            default:
                return nil
            }
        }
    }
    
    private func applyInitialSnapshot() {
        // TODO: Replace with ViewModel outputs
        let regions: [RegionItem] = [
            .init(iconImage: .iconTaegeuk, organization: "국토 교통부", title: "강남역 집회 예정", description: "2025.10.01일 오후 2시부터 4시까지 강남역 일대 교통 혼잡이 예상됩니다."),
            .init(iconImage: .iconTaegeuk, organization: "식약처", title: "강남역 집회 예정", description: "2025.10.01일 오후 2시부터 4시까지 강남역 일대 교통 혼잡이 예상됩니다."),
            .init(iconImage: .iconTaegeuk, organization: "소방처", title: "강남역 집회 예정", description: "2025.10.01일 오후 2시부터 4시까지 강남역 일대 교통 혼잡이 예상됩니다.")
        ]
        
        let imageTexts1: [RecommendPlaceItem] = [
            .init(image: .dummy, title: "노들섬", address: "서울 강남구", congestion: CongestionLevel.normal),
            .init(image: .dummy, title: "노들섬", address: "서울 강남구", congestion: CongestionLevel.busy),
            .init(image: .dummy, title: "노들섬", address: "서울 강남구", congestion: CongestionLevel.crowded)
        ]
        
        let imageTexts2: [RecommendPlaceItem] = [
            .init(image: .dummy, title: "노들섬", address: "서울 강남구", congestion: CongestionLevel.normal),
            .init(image: .dummy, title: "노들섬", address: "서울 강남구", congestion: CongestionLevel.busy),
            .init(image: .dummy, title: "노들섬", address: "서울 강남구", congestion: CongestionLevel.crowded)
        ]
        
        let favorites: [FavoritePlaceItem] = [
            .init(image: .dummy, title: "강남역 2번 출구", update: 15, congestion: .busy),
            .init(image: .dummy, title: "강남역 2번 출구", update: 5, congestion: .normal),
            .init(image: .dummy, title: "강남역 2번 출구", update: 8, congestion: .relaxed)
        ]
        
        let congestionRank: [CongestionRankPlaceItem] = [
            .init(rank: 1, image: .dummy, title: "서울역", address: "서울 강남구", update: 3, congestion: .crowded),
            .init(rank: 2, image: .dummy, title: "서울역", address: "서울 강남구", update: 12, congestion: .busy),
            .init(rank: 3, image: .dummy, title: "서울역", address: "서울 강남구", update: 10, congestion: .busy),
            .init(rank: 4, image: .dummy, title: "서울역", address: "서울 강남구", update: 6, congestion: .normal),
            .init(rank: 5, image: .dummy, title: "서울역", address: "서울 강남구", update: 15, congestion: .relaxed),
        ]
        
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeItem>()
        snapshot.appendSections(HomeSection.allCases)
        snapshot.appendItems([.region(regions)], toSection: .region)
        snapshot.appendItems(imageTexts1.map { .recommendPlace($0) }, toSection: .recommendPlace1)
        snapshot.appendItems(imageTexts2.map { .recommendPlace($0) }, toSection: .recommendPlace2)
        snapshot.appendItems(favorites.map { .favoritePlace($0) }, toSection: .favoritePlace)
        snapshot.appendItems(congestionRank.map { .congestionRank($0) }, toSection: .congestionRank)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: Layout
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, env -> NSCollectionLayoutSection? in
            guard let sectionKind = HomeSection(rawValue: sectionIndex) else { return nil }
            switch sectionKind {
            case .region:
                return Self.makeRegionSection(env: env)
            case .recommendPlace1:
                return Self.makeRecommendPlaceSection(env: env, inset: true)
            case .recommendPlace2:
                return Self.makeRecommendPlaceSection(env: env, inset: false)
            case .favoritePlace:
                return Self.makeFavoritePlaceSection(env: env)
            case .congestionRank:
                return Self.makeCongestionRankSection(env: env)
            }
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 16
        layout.configuration = config
        
        return layout
    }
    
    private static func makeRegionSection(env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(151))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 14, leading: 16, bottom: 0, trailing: 16)
        
        section.boundarySupplementaryItems = [self.sectionHeader()]
        
        return section
    }
    
    private static func makeRecommendPlaceSection(env: NSCollectionLayoutEnvironment, inset: Bool) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .absolute(230))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        if inset {
            section.contentInsets = .init(top: 14, leading: 16, bottom: 0, trailing: 16)
        } else {
            section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        }
        
        section.interGroupSpacing = 14
        
        section.boundarySupplementaryItems = [self.sectionHeader()]
        
        return section
    }
    
    private static func makeFavoritePlaceSection(env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(180), heightDimension: .estimated(230))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        section.contentInsets = .init(top: 14, leading: 16, bottom: 0, trailing: 16)
        section.interGroupSpacing = 12
        
        section.boundarySupplementaryItems = [self.sectionHeader()]
        
        return section
    }
    
    private static func makeCongestionRankSection(env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        
        let sepSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(15))
        let sepAnchor = NSCollectionLayoutAnchor(edges: [.bottom])
        let separator = NSCollectionLayoutSupplementaryItem(layoutSize: sepSize, elementKind: SeparatorView.elementKind, containerAnchor: sepAnchor)
        
        separator.contentInsets = .zero // .init(top: 14, leading: 0, bottom: 14, trailing: 0)
        let item = NSCollectionLayoutItem(layoutSize: itemSize, supplementaryItems: [separator])
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(105))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        
        section.contentInsets = .init(top: 14, leading: 16, bottom: 0, trailing: 16)
        section.interGroupSpacing = 14
        
        section.boundarySupplementaryItems = [self.sectionHeader()]
        
        return section
    }
    
    // CollectionView section별 헤더
    private static func sectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(34))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: size, elementKind: TitleHeaderView.elementKind, alignment: .top)
        
        header.pinToVisibleBounds = false
        header.contentInsets = .init(top: 8, leading: 0, bottom: 8, trailing: 0)
        return header
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
//        case .bookmarkPlace(let place):
//            viewModel.didSelectPlace(place)
        default:
            break
        }
    }
}
