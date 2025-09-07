//
//  FavoriteViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/21/25.
//

import UIKit
import RxSwift
import RxCocoa

final class FavoriteViewController: UIViewController {
    private let viewModel: FavoriteViewModel
    private let disposeBag = DisposeBag()
    
    private let emptyStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 16
        
        return stackView
    }()
    
    private let emptyIllustrationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .illustrationNotification
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.medium.font
        label.textColor = .grayScale10
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "질문이 없습니다"
        
        return label
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<FavoriteSection, FavoritePlaceItem>!
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .white
        collectionView.directionalLayoutMargins = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        collectionView.contentInset.top = 22 // 최상단 간격
        
        return collectionView
    }()
    
    init(viewModel: FavoriteViewModel) {
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
    
    private func bind() {
        viewModel.output.items
                .map { $0.isEmpty }
                .drive(onNext: { [weak self] isEmpty in
                    guard let self else { return }
                    self.emptyStackView.isHidden = !isEmpty
                    self.collectionView.isHidden = isEmpty
                })
                .disposed(by: disposeBag)
        
        viewModel.output.items
            .map { $0.map(Self.makeItem(_:)) }
            .drive(onNext: { [weak self] items in
                self?.applySnapshot(items)
            })
            .disposed(by: disposeBag)
    }
    
    private static func makeItem(_ f: MyFavorite) -> FavoritePlaceItem {
        if let congestion = f.congestionLevelName {
            return FavoritePlaceItem(
                image: f.imageUrl ?? "",
                title: f.name,
                update: TimeAgo.displayString(from: f.observedAt ?? ""),
                congestion: CongestionLevel.init(ko: congestion))
        } else {
            return FavoritePlaceItem(
                image: f.imageUrl ?? "",
                title: f.name,
                update: TimeAgo.displayString(from: f.observedAt ?? ""),
                congestion: nil)
        }
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        configureCollectionView()
        configureDataSource()
        configureEmptyStackView()
        
//        applySnapshot()
    }
    
    private func configureEmptyStackView() {
        [emptyIllustrationImageView, emptyTitleLabel].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            emptyStackView.addArrangedSubview(view)
        }
        
        emptyStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStackView)
        
        NSLayoutConstraint.activate([
            emptyStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            emptyStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.register(FavoritePlaceCell.self, forCellWithReuseIdentifier: FavoritePlaceCell.identifier)
        collectionView.contentInsetAdjustmentBehavior = .always
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<FavoriteSection, FavoritePlaceItem>( collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoritePlaceCell.identifier, for: indexPath) as! FavoritePlaceCell
            
            cell.configure(item)
            
            return cell
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let columns = 2
        let aspect: CGFloat = 1.3
        let groupHeightFraction = aspect / CGFloat(columns)

        // 아이템은 그룹 높이를 그대로 채우게 설정
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // 그룹 높이를 섹션 "너비의 0.75배"로
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(groupHeightFraction)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
        group.interItemSpacing = .fixed(8)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 24
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

        return UICollectionViewCompositionalLayout(section: section)
    }
    
//    private func applySnapshot() {
//        let favoriteItems: [FavoritePlaceItem] = [
//            .init(image: "", title: "롯데타워", update: 10, congestion: .busy),
//            .init(image: "", title: "롯데타워", update: 10, congestion: .crowded),
//            .init(image: "", title: "롯데타워", update: 10, congestion: .busy),
//            .init(image: "", title: "롯데타워", update: 10, congestion: .normal),
//            .init(image: "", title: "롯데타워", update: 10, congestion: .relaxed),
//            .init(image: "", title: "롯데타워", update: 10, congestion: .crowded),
//        ]
//        
//        var snapshot = NSDiffableDataSourceSnapshot<FavoriteSection, FavoritePlaceItem>()
//        snapshot.appendSections([.main])
//        snapshot.appendItems(favoriteItems, toSection: .main)
//        dataSource.apply(snapshot, animatingDifferences: true)
//    }
    
    private func applySnapshot(_ items: [FavoritePlaceItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<FavoriteSection, FavoritePlaceItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension FavoriteViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        
        print("index : \(index)")
    }
}
