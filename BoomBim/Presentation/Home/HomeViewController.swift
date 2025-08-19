//
//  HomeViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit

final class HomeViewController: UIViewController {
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
    
    private func setupView() {
        view.backgroundColor = .white
        
        setupNavigationBar()
        
        configureCollectionView()
        configureDataSource()
        
        setupFloatingButton()
        
        applyInitialSnapshot() // dummy Data
    }
    
    // MARK: Setup UI
    private func setupNavigationBar() {
        let logoImageView = UIImageView(image: .logoText)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let logoItem = UIBarButtonItem(customView: logoImageView)
        navigationItem.leftBarButtonItem = logoItem
        
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
        collectionView.register(RegionCardCell.self, forCellWithReuseIdentifier: RegionCardCell.reuseID)
        
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
        
        let imageTextRegistration = UICollectionView.CellRegistration<ImageTextCell, ImageTextItem> { cell, _, item in
            cell.configure(item)
        }
        
        let placeRegistration = UICollectionView.CellRegistration<PlaceCell, PlaceItem> { cell, _, item in
            cell.configure(item)
        }
        
        // Header 설정
        let headerRegistration = UICollectionView.SupplementaryRegistration<TitleHeaderView>(elementKind: TitleHeaderView.elementKind) { [weak self] header, _, indexPath in
            guard let section = HomeSection(rawValue: indexPath.section) else { return }
            
            if let title = section.headerTitle, let image = section.headerImage {
                header.configure(image: image, text: title)
            } else if let title = section.headerTitle {
                header.configure(text: title)
            }
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
            .init(iconImage: .iconTaegeuk, organization: "국토 교통부", title: "강남역 집회 예정", description: "2025.10.01일 오후 2시부터 4시까지 강남역 일대 교통 혼잡이 예상됩니다."),
            .init(iconImage: .iconTaegeuk, organization: "식약처", title: "강남역 집회 예정", description: "2025.10.01일 오후 2시부터 4시까지 강남역 일대 교통 혼잡이 예상됩니다."),
            .init(iconImage: .iconTaegeuk, organization: "소방처", title: "강남역 집회 예정", description: "2025.10.01일 오후 2시부터 4시까지 강남역 일대 교통 혼잡이 예상됩니다.")
        ]
        
        let imageTexts1: [ImageTextItem] = [
            .init(image: .dummy, title: "노들섬", address: "서울 강남구", congestion: CongestionLevel.normal),
            .init(image: .dummy, title: "노들섬", address: "서울 강남구", congestion: CongestionLevel.busy),
            .init(image: .dummy, title: "노들섬", address: "서울 강남구", congestion: CongestionLevel.crowded)
        ]
        
        let imageTexts2: [ImageTextItem] = [
            .init(image: .dummy, title: "노들섬", address: "서울 강남구", congestion: CongestionLevel.normal),
            .init(image: .dummy, title: "노들섬", address: "서울 강남구", congestion: CongestionLevel.busy),
            .init(image: .dummy, title: "노들섬", address: "서울 강남구", congestion: CongestionLevel.crowded)
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
        snapshot.appendItems([.region(regions)], toSection: .region)
        snapshot.appendItems(imageTexts1.map { .imageText($0) }, toSection: .recommendPlace1)
        snapshot.appendItems(imageTexts2.map { .imageText($0) }, toSection: .recommendPlace2)
        snapshot.appendItems(favorites.map { .place($0) }, toSection: .favorites)
        snapshot.appendItems(crowded.map { .place($0) }, toSection: .congestion)
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
                return Self.makeImageTextSection(env: env, inset: true)
            case .recommendPlace2:
                return Self.makeImageTextSection(env: env, inset: false)
            case .favorites, .congestion:
                return Self.makeListSection(env: env, hasHeader: true)
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
    
    private static func makeImageTextSection(env: NSCollectionLayoutEnvironment, inset: Bool) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .absolute(180))
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
    
    private static func makeListSection(env: NSCollectionLayoutEnvironment, hasHeader: Bool) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(56))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(56))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(8)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = .init(top: 8, leading: 16, bottom: 16, trailing: 16)
        
        section.boundarySupplementaryItems = [self.sectionHeader()]
        
        return section
    }
    
    // CollectionView section별 헤더
    private static func sectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(34))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: size, elementKind: TitleHeaderView.elementKind, alignment: .top)
        
        header.pinToVisibleBounds = false
        header.contentInsets = .init(top: 8, leading: 0, bottom: 8, trailing: 16)
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
        case .place(let place):
            viewModel.didSelectPlace(place)
        default:
            break
        }
    }
}
