//
//  UserPlaceDetailViewController.swift
//  BoomBim
//
//  Created by 조영현 on 9/5/25.
//

import UIKit
import RxSwift
import RxCocoa

typealias FeedItem = MemberCongestionItem

final class UserPlaceDetailViewController: UIViewController {
    // MARK: - State
    private let disposeBag = DisposeBag()
    private let filterRelay = BehaviorRelay<FeedFilter>(value: .latest)
    private let allItemsRelay = BehaviorRelay<[FeedItem]>(value: [])
    private var pendingData: UserPlaceDetailInfo?   // view가 아직 안 떠있을 때 보관

    // MARK: - UI
    private let viewTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.semiBold.font
        label.textColor = .grayScale10
        label.textAlignment = .center
        label.text = "place.detail.label.title.user".localized()
        
        return label
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(.iconUnselectedFavorite, for: .normal)
        button.setImage(.iconSelectedFavorite, for: .selected)
        button.contentMode = .scaleAspectFit
        
        return button
    }()
    
    private let spacingView: UIView = {
        let view = UIView()
        view.backgroundColor = .viewDivider
        
        return view
    }()
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let filterBar = FilterBarView()
    private var headerView = PlaceHeaderView(
        title: "—", meta: "—", currentLevel: .normal
    )
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupView()
        bindTable()
        
        // view가 뜬 뒤에 pendingData가 있으면 반영
        if let data = pendingData {
            apply(data)
            pendingData = nil
        }
    }
    
    // MARK: - Public: 외부에서 데이터 주입
    func configure(data: UserPlaceDetailInfo) {
        if isViewLoaded {
            apply(data)
        } else {
            pendingData = data
        }
    }
    
    // MARK: - Private helpers
    private func apply(_ data: UserPlaceDetailInfo) {
        headerView.update(title: data.memberPlaceSummary.name, meta: data.memberPlaceSummary.address, level: CongestionLevel(ko: data.memberCongestionItems.first?.congestionLevelName ?? "여유") ?? .relaxed)
        
        // 목록 데이터 반영
        allItemsRelay.accept(data.memberCongestionItems)
        
        // 필터 초기화 + 맨 위로 스크롤
        filterBar.select(.latest)
        filterRelay.accept(.latest)
        tableView.setContentOffset(
            CGPoint(x: 0, y: -tableView.adjustedContentInset.top),
            animated: false
        )
    }
    
    private func setupView() {
        configureTitle()
        configureHeader()
        configureFilterBar()
        configureTableView()
    }
    
    private func configureTitle() {
        [viewTitleLabel, favoriteButton].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            viewTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            viewTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewTitleLabel.heightAnchor.constraint(equalToConstant: 46),
            
            favoriteButton.centerYAnchor.constraint(equalTo: viewTitleLabel.centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func configureHeader() {
        [headerView, spacingView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: viewTitleLabel.bottomAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            spacingView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            spacingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            spacingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            spacingView.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    private func configureFilterBar() {
        filterBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterBar)
        
        NSLayoutConstraint.activate([
            filterBar.topAnchor.constraint(equalTo: spacingView.bottomAnchor, constant: 20),
            filterBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // 필터 높이만큼 inset
//        view.layoutIfNeeded()
//        let h = filterBar.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
//        tableView.contentInset.top = h
//        tableView.scrollIndicatorInsets.top = h
        
        // 선택 콜백
        filterBar.onChange = { [weak self] filter in
            self?.filterRelay.accept(filter)
        }
    }
    
    private func configureTableView() {
        tableView.backgroundColor = UIColor(white: 0.98, alpha: 1)
        tableView.separatorStyle = .none
        tableView.register(FeedTableViewCell.self, forCellReuseIdentifier: FeedTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
        // 레이아웃
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: filterBar.bottomAnchor, constant: 6),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func bindTable() {
        // 필터링
        Observable
            .combineLatest(allItemsRelay.asObservable(), filterRelay.asObservable())
            .map { items, filter -> [FeedItem] in
                switch filter {
                case .latest:        return items
                case .crowded:       return items.filter { $0.congestionLevelName == FeedFilter.crowded.title }
                case .busy:          return items.filter { $0.congestionLevelName == FeedFilter.busy.title }
                case .normal:        return items.filter { $0.congestionLevelName == FeedFilter.normal.title }
                case .relaxed:       return items.filter { $0.congestionLevelName == FeedFilter.relaxed.title }
                }
            }
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: FeedTableViewCell.identifier, cellType: FeedTableViewCell.self)) { _, item, cell in
                cell.apply(item)
            }
            .disposed(by: disposeBag)
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        // 회전 등으로 필터 높이가 바뀌면 inset 재적용
//        let h = filterBar.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
//        if tableView.contentInset.top != h {
//            tableView.contentInset.top = h
//            tableView.scrollIndicatorInsets.top = h
//        }
//    }
}
