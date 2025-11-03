//
//  HomeViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeViewController: BaseViewController {
    private let viewModel: HomeViewModel
    private let disposeBag = DisposeBag()
    private let refreshFavoriteRelay = PublishRelay<Void>()
    private let refreshRankRelay = PublishRelay<Void>()
    
    // applyInitialSnapshot 진행할 때 데이터 유무 확인
    private var lastFavoritesWasEmpty = true
    private var lastRegionWasEmpty = true
    
    private var dataSource: UICollectionViewDiffableDataSource<HomeSection, HomeItem>!
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .background
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
    
    private var currentRegions: [RegionItem] = []
    private var currentRecommend: [RecommendPlaceItem] = []
    private var currentFavorites: [FavoritePlaceItem] = []
    private var currentCongestionRanks: [CongestionRankPlaceItem] = []
    
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
        
        bind()
    }
    
    // MARK: - Binding
    private func bind() {
        let output = viewModel.transform(.init(
            appear: rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:)))
                .map { _ in () },
            refreshFavorite: refreshFavoriteRelay.asObservable(),
            refreshRank: refreshRankRelay.asObservable()
        ))
        
        let regions = output.regionNewsItems.asObservable()
        let recommends = output.nearbyOfficialPlace.asObservable()
        let favorites = output.favoritePlace.asObservable()
        let ranks = output.rankOfficialPlace.asObservable()

        Observable
            .combineLatest(regions, recommends, favorites, ranks)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] regions, recommends, favorites, ranks in
                self?.currentRegions = regions
                self?.currentRecommend = recommends
                self?.currentFavorites = favorites
                self?.currentCongestionRanks = ranks
                self?.applyInitialSnapshot()
            })
            .disposed(by: disposeBag)

        output.errorMessage
            .emit(onNext: { [weak self] msg in
                self?.presentAlert(title: "오류", message: msg)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Setup UI
    private func setupView() {
        view.backgroundColor = .background
        
        setupNavigationBar()
        
        configureCollectionView()
        configureDataSource()
        
        setupFloatingButton()
        
        applyInitialSnapshot()
    }
    
    private func setupNavigationBar() {
        let logoImageView = UIImageView(image: .logoText)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let logoItem = UIBarButtonItem(customView: logoImageView)
        navigationItem.leftBarButtonItem = logoItem
        
//        let searchButton = UIButton(type: .system)
//        searchButton.setImage(.iconSearch, for: .normal)
//        searchButton.tintColor = .grayScale9
//        searchButton.addTarget(self, action: #selector(didTapSearchButton), for: .touchUpInside)

        let notificationButton = UIButton(type: .system)
        notificationButton.setImage(.iconAlarm, for: .normal)
        notificationButton.tintColor = .grayScale9
        notificationButton.addTarget(self, action: #selector(didTapNotificationButton), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [notificationButton/*, searchButton*/])
//        stack.axis = .horizontal
//        stack.spacing = 12

        let barItem = UIBarButtonItem(customView: stack)
        navigationItem.rightBarButtonItem = barItem
    }
    
    private func setupFloatingButton() {
        view.addSubview(floatingButton)
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            floatingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
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
        
        let regionEmptyRegistration = UICollectionView.CellRegistration<RegionEmptyCell, String> { cell, _, _ in }
        
        let recommendRegistration = UICollectionView.CellRegistration<RecommendPlaceCell, RecommendPlaceItem> { cell, _, item in
            cell.configure(item)
        }
        
        let favoriteRegistration = UICollectionView.CellRegistration<FavoriteCell, FavoritePlaceItem> { cell, _, item in
            cell.configure(item)
            cell.onTapFavorite = { [weak self] in
                guard let self else { return }
                
                self.viewModel.removeFavoritePlace(item)
                    .emit(with: self) { owner, _ in
                        print("삭제")
                        self.refreshFavoriteRelay.accept(())
                    }.disposed(by: disposeBag)
            }
        }
        
        let favoriteEmptyRegistration = UICollectionView.CellRegistration<FavoriteEmptyCell, String> { cell, _, _ in }
        
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
                self?.refreshRankRelay.accept(())
            })
        }
        
        let sectionSpacerRegistration = UICollectionView.SupplementaryRegistration<SectionSpacerView>(
            elementKind: SectionSpacerView.elementKind) { view, _, indexPath in
            view.isHidden = (indexPath.section == HomeSection.allCases.count - 1) // 마지막 섹션은 숨김
        }
        
        let separatorRegistration = UICollectionView.SupplementaryRegistration<SeparatorView>(elementKind: SeparatorView.elementKind) { separator, _, indexPath in
            guard let section = HomeSection(rawValue: indexPath.section) else { return }
            
            separator.configure()
        }
        
        dataSource = UICollectionViewDiffableDataSource<HomeSection, HomeItem>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .region(let m):
                return collectionView.dequeueConfiguredReusableCell(using: regionRegistration, for: indexPath, item: m)
            case .regionEmpty:
                return collectionView.dequeueConfiguredReusableCell(using: regionEmptyRegistration, for: indexPath, item: "empty")
            case .recommendPlace(let m):
                return collectionView.dequeueConfiguredReusableCell(using: recommendRegistration, for: indexPath, item: m)
            case .favoritePlace(let m):
                return collectionView.dequeueConfiguredReusableCell(using: favoriteRegistration, for: indexPath, item: m)
            case .favoriteEmpty:
                return collectionView.dequeueConfiguredReusableCell(using: favoriteEmptyRegistration, for: indexPath, item: "empty")
            case .congestionRank(let m):
                return collectionView.dequeueConfiguredReusableCell(using: congestionRankRegistration, for: indexPath, item: m)
            }
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self else { return nil }
            
            switch kind {
            case TitleHeaderView.elementKind:
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
                
            case SectionSpacerView.elementKind:
                        return collectionView.dequeueConfiguredReusableSupplementary(using: sectionSpacerRegistration, for: indexPath)
                
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
        // 1) 스냅샷 구성
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeItem>()
        snapshot.appendSections(HomeSection.allCases)

        // Region: 단일 아이템 (고정 ID)
        let isRegionEmpty = currentRegions.isEmpty
        if isRegionEmpty {
            snapshot.appendItems([.regionEmpty], toSection: .region)
        } else {
            snapshot.appendItems([.region(currentRegions)], toSection: .region)
        }

        // Recommend: id 기준 중복 제거
        print("recommendPlace : \(currentRecommend)")
        let uniqueRecommend = Array(currentRecommend.map(\.id)).compactMap { id in
            currentRecommend.first { $0.id == id }
        }
        print("uniqueRecommend : \(uniqueRecommend)")
        snapshot.appendItems(uniqueRecommend.map { .recommendPlace($0) }, toSection: .recommendPlace)

        // Favorite: empty placeholder 또는 id 중복 제거
        let favoritesIsEmpty = currentFavorites.isEmpty
        if favoritesIsEmpty {
            snapshot.appendItems([.favoriteEmpty], toSection: .favoritePlace)
        } else {
            let uniqueFavorites = Array(currentFavorites.map(\.placeId)).compactMap { id in
                currentFavorites.first { $0.placeId == id }
            }
            snapshot.appendItems(uniqueFavorites.map { .favoritePlace($0) }, toSection: .favoritePlace)
        }

        // Rank: 필요시 중복 제거 가능 (보통 서버가 유일 보장)
        snapshot.appendItems(currentCongestionRanks.map { .congestionRank($0) }, toSection: .congestionRank)

        // 3) 레이아웃 바뀔 수 있는 전환인가? (placeholder ↔ list)
        let toggledFavoritesPlaceholder = (lastFavoritesWasEmpty != favoritesIsEmpty)
        let toggledRegionPlaceholder = (lastRegionWasEmpty != isRegionEmpty)

        // 4) 적용: 전환 시엔 reload가 더 안전, 그 외에는 diff
        if toggledFavoritesPlaceholder || toggledRegionPlaceholder {
            // 레이아웃이 달라질 수 있으므로(특히 Favorite 섹션) reload 권장
            dataSource.applySnapshotUsingReloadData(snapshot)
            // 필요하면 이 타이밍에 레이아웃을 재설정
            // collectionView.setCollectionViewLayout(createLayout(), animated: false)
        } else {
            dataSource.apply(snapshot, animatingDifferences: true)
        }

        // 5) 상태 업데이트
        lastFavoritesWasEmpty = favoritesIsEmpty
        lastRegionWasEmpty = isRegionEmpty
    }
    
    // MARK: Layout
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, env -> NSCollectionLayoutSection? in
            guard let sectionKind = HomeSection(rawValue: sectionIndex) else { return nil }
            switch sectionKind {
            case .region:
                return Self.makeRegionSection(env: env)
            case .recommendPlace:
                return Self.makeRecommendPlaceSection(env: env, inset: true)
            case .favoritePlace:
                return Self.makeFavoritePlaceSection(env: env, isEmpty: self?.currentFavorites.isEmpty ?? true)
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
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(180))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(180))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10, leading: 16, bottom: 24, trailing: 16)
        
        section.boundarySupplementaryItems = [self.sectionHeader(), self.sectionSpacerFooter()]
        
        return section
    }
    
    private static func makeRecommendPlaceSection(env: NSCollectionLayoutEnvironment, inset: Bool = true) -> NSCollectionLayoutSection {
        
        // 1) 카드(셀) 한 장 = 열(column) 안에서의 "행" 하나
        //    열 그룹 높이의 1/2씩 차지하도록 설정 (총 2행)
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                              heightDimension: .fractionalHeight(0.5))
        )
        
        // 2) "열(column) 그룹)" = 세로로 2개 아이템을 쌓음
        let groupHeight: CGFloat = 380        // 전체 높이 (디자인에 맞게 조정)
        let columnWidthRatio: CGFloat = 0.8   // 화면 폭 대비 열 하나의 너비 비율 (0.45 ~ 0.9 사이로 조절하면 보이는 칼럼 수가 달라짐)
        
        let columnGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(
                widthDimension: .absolute(env.container.effectiveContentSize.width * columnWidthRatio),
                heightDimension: .estimated(groupHeight)
            ),
            subitem: item,
            count: 2
        )
        columnGroup.interItemSpacing = .fixed(16) // 두 행 사이 간격
        
        // 3) 섹션: 열 그룹을 "가로로" 나열 (orthogonalScrolling)
        let section = NSCollectionLayoutSection(group: columnGroup)
        section.orthogonalScrollingBehavior = .continuous // .continuousGroupLeadingBoundary / .groupPaging 등 취향대로
        
        if inset {
            section.contentInsets = .init(top: 14, leading: 16, bottom: 24, trailing: 16)
        } else {
            section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        }
        
        // 열(=그룹) 사이 가로 간격
        section.interGroupSpacing = 14
        
        // 헤더가 있다면 그대로 유지
        section.boundarySupplementaryItems = [self.sectionHeader(), self.sectionSpacerFooter()]
        
        return section
    }
    
    private static func makeFavoritePlaceSection(env: NSCollectionLayoutEnvironment, isEmpty: Bool) -> NSCollectionLayoutSection {
        if isEmpty {
            // 플레이스홀더: 한 장, 가로 전체
            let item = NSCollectionLayoutItem(
                layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                  heightDimension: .estimated(92))
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                  heightDimension: .estimated(92)),
                subitems: [item]
            )
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 14, leading: 16, bottom: 24, trailing: 16)
            section.boundarySupplementaryItems = [self.sectionHeader(), self.sectionSpacerFooter()]
            return section
        } else {
            // 기존 가로 스크롤 카드들
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                heightDimension: .fractionalHeight(1.0)))
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(widthDimension: .absolute(180), heightDimension: .estimated(230)),
                subitems: [item]
            )
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = .init(top: 14, leading: 16, bottom: 24, trailing: 16)
            section.interGroupSpacing = 12
            
            section.boundarySupplementaryItems = [self.sectionHeader(), self.sectionSpacerFooter()]
            return section
        }
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
        
        section.contentInsets = .init(top: 14, leading: 16, bottom: 50, trailing: 16)
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
    
    private static func sectionSpacerFooter(height: CGFloat = 8) -> NSCollectionLayoutBoundarySupplementaryItem {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(height)
        )
        let footer = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: size,
            elementKind: SectionSpacerView.elementKind,
            alignment: .bottom
        )
        footer.extendsBoundary = true   // 섹션 좌우 contentInsets 무시하고 꽉 채우기
        footer.contentInsets = .init(top: 0, leading: -16, bottom: 0, trailing: -16)
        footer.pinToVisibleBounds = false
        
        return footer
    }
    
    // MARK: Action
    @objc private func didTapFloatingButton() {
        viewModel.didTapFloating()
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
