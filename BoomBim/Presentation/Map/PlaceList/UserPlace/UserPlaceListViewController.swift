//
//  UserPlaceListViewController.swift
//  BoomBim
//
//  Created by 조영현 on 9/5/25.
//

import UIKit
import RxSwift
import RxCocoa

extension UserPlaceItem: Hashable {
    static func == (lhs: UserPlaceItem, rhs: UserPlaceItem) -> Bool {
        return lhs.memberPlaceId == rhs.memberPlaceId
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(memberPlaceId)
    }
}

final class UserPlaceListViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    // 셀에서 올라오는 탭(payload) → 외부로 FavoriteAction 방출
    private let favoriteTapRelay = PublishRelay<FavoriteTapPayload>()
    var favoriteActionRequested: Signal<FavoriteAction> {
        favoriteTapRelay
            .throttle(.milliseconds(400), latest: false, scheduler: MainScheduler.instance)
            .map { p in
                p.isFavorite
                ? .remove(RemoveFavoritePlaceRequest(placeType: p.placeType, placeId: p.placeId))
                : .add(RegisterFavoritePlaceRequest(placeType: p.placeType, placeId: p.placeId))
            }
            .asSignal(onErrorSignalWith: .empty())
    }
    
    // MARK: Public
    enum Section { case main }

    let tableView = UITableView(frame: .zero, style: .plain)
    var onOfficialSelect: ((OfficialPlaceItem) -> Void)?
    var onUserSelect: ((UserPlaceItem) -> Void)?

    // 외부에서 헤더 타이틀 바꾸기
    func updateHeader(title: String) {
        headerLabel.text = title
        layoutHeader()
    }
    
    func apply(places: [UserPlaceItem], animate: Bool = true) {
        userItems = places
        var snapshot = NSDiffableDataSourceSnapshot<Section, UserPlaceItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(places, toSection: .main)
        userDataSource.apply(snapshot, animatingDifferences: animate)
        emptyView.isHidden = !places.isEmpty
    }
    
    func applyFavoriteChange(placeId: Int, isFavorite: Bool) {
        // 1) 모델 업데이트
        guard let idx = userItems.firstIndex(where: { $0.memberPlaceId == placeId }) else { return }
        userItems[idx].isFavorite = isFavorite
        let item = userItems[idx]

        // 2) 보이는 셀이면 버튼만 즉시 토글
        if let indexPath = userDataSource.indexPath(for: item),
           let cell = tableView.cellForRow(at: indexPath) as? UserPlaceInfoCell {
            cell.setFavoriteSelected(isFavorite) // 셀에 헬퍼 추가
            // 끝. (스냅샷 적용 불필요)
        } else {
            // 3) 화면에 없으면 다음 표시를 위해 최소 갱신
            var snapshot = userDataSource.snapshot()
            snapshot.reloadItems([item])            // iOS 15+면 reconfigureItems([item]) 권장
            userDataSource.apply(snapshot, animatingDifferences: false)
        }
    }

    // MARK: Private
    private var userItems: [UserPlaceItem] = []
    private lazy var userDataSource = makeUserDataSource()

    // Header
    private let headerContainer = UIView()
    private let grabber = UIView()
    private let headerStack = UIStackView()
    private let headerIcon = UIImageView(image: UIImage(systemName: "location.circle.fill"))
    private let headerLabel = UILabel()

    // Empty state
    private let emptyView = UILabel()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        layout()
        layoutHeader()
    }
}

// MARK: - Configure & Layout
private extension UserPlaceListViewController {
    func configure() {
        view.backgroundColor = .clear

        // TableView
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = true
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UserPlaceInfoCell.self, forCellReuseIdentifier: UserPlaceInfoCell.identifier)
        tableView.delegate = self

        // Header (안쪽 카드가 아니라 테이블 상단 고정 헤더)
        headerContainer.backgroundColor = .clear

        grabber.backgroundColor = UIColor.secondaryLabel.withAlphaComponent(0.35)
        grabber.layer.cornerRadius = 2.5

        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 8

        headerIcon.tintColor = .label
        headerIcon.setContentCompressionResistancePriority(.required, for: .horizontal)

        headerLabel.text = "주변 혼잡도를 확인해보세요 !"
        headerLabel.font = Typography.Body01.medium.font
        headerLabel.adjustsFontForContentSizeCategory = true
        headerLabel.textColor = .grayScale10

        // Empty
        emptyView.text = "주변에 표시할 장소가 없어요"
        emptyView.textAlignment = .center
        emptyView.textColor = .secondaryLabel
        emptyView.numberOfLines = 0
        emptyView.isHidden = true
    }

    func layout() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Header as tableHeaderView
        headerContainer.addSubview(grabber)
        headerContainer.addSubview(headerStack)
        headerStack.addArrangedSubview(headerIcon)
        headerStack.addArrangedSubview(headerLabel)

        tableView.tableHeaderView = headerContainer

        // Empty view overlay
        view.addSubview(emptyView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }

    // tableHeaderView는 frame 기반이므로 오토레이아웃 후 크기 재계산 필요
    func layoutHeader() {
        let width = view.bounds.width
        let contentInsetTop: CGFloat = 4
        let grabberTop: CGFloat = 8

        headerContainer.translatesAutoresizingMaskIntoConstraints = false
//        grabber.translatesAutoresizingMaskIntoConstraints = false
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.deactivate(headerContainer.constraints + grabber.constraints + headerStack.constraints)

        NSLayoutConstraint.activate([


            headerStack.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 45),
            headerStack.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(lessThanOrEqualTo: headerContainer.trailingAnchor, constant: -16),
            headerStack.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -12)
        ])

        // 헤더의 실제 높이 계산
        headerContainer.setNeedsLayout()
        headerContainer.layoutIfNeeded()
        let targetHeight: CGFloat = grabberTop + 5 + 12 + headerStack.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + 12 + contentInsetTop + 30
        headerContainer.frame = CGRect(x: 0, y: 0, width: width, height: targetHeight)
        tableView.tableHeaderView = headerContainer
    }
    
    func makeUserDataSource() -> UITableViewDiffableDataSource<Section, UserPlaceItem> {
        let ds = UITableViewDiffableDataSource<Section, UserPlaceItem>(tableView: tableView) { [weak self] tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: UserPlaceInfoCell.identifier, for: indexPath) as? UserPlaceInfoCell else {
                return UITableViewCell(style: .default, reuseIdentifier: "fallback")
            }
            cell.configure(with: item)
            
            cell.onFavoriteTapped = { [weak self] in
                guard let self else { return }
                
                print("이름이 무엇 item : \(item.name)")
                
                let payload = FavoriteTapPayload(
                    placeId: item.memberPlaceId,
                    placeType: .MEMBER_PLACE,
                    isFavorite: item.isFavorite,
                    indexPath: indexPath
                )
                
                self.favoriteTapRelay.accept(payload)
            }
            
            return cell
        }
        return ds
    }
}

// MARK: - UITableViewDelegate
extension UserPlaceListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let userItem = userDataSource.itemIdentifier(for: indexPath) {
            onUserSelect?(userItem)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // 카드 사이 여백 조금 추가 (섹션 헤더/푸터 대신)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
