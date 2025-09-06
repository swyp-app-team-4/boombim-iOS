//
//  FavoriteViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/21/25.
//

import UIKit

final class FavoriteViewController: UIViewController {
    
    private var dataSource: UICollectionViewDiffableDataSource<FavoriteSection, FavoritePlaceItem>!
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .white
        collectionView.directionalLayoutMargins = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        collectionView.contentInset.top = 22 // 최상단 간격
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        configureCollectionView()
        configureDataSource()
        
        applySnapshot()
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
    
    private func applySnapshot() {
        let favoriteItems: [FavoritePlaceItem] = [
            .init(image: "", title: "롯데타워", update: 10, congestion: .busy),
            .init(image: "", title: "롯데타워", update: 10, congestion: .crowded),
            .init(image: "", title: "롯데타워", update: 10, congestion: .busy),
            .init(image: "", title: "롯데타워", update: 10, congestion: .normal),
            .init(image: "", title: "롯데타워", update: 10, congestion: .relaxed),
            .init(image: "", title: "롯데타워", update: 10, congestion: .crowded),
        ]
        
        var snapshot = NSDiffableDataSourceSnapshot<FavoriteSection, FavoritePlaceItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(favoriteItems, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension FavoriteViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        
        print("index : \(index)")
    }
}
