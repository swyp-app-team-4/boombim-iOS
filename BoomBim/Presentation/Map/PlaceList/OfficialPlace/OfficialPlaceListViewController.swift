//
//  PlaceListViewController.swift
//  BoomBim
//
//  Created by 조영현 on 9/1/25.
//

import UIKit
import RxSwift
import RxCocoa

// 고유 id로만 동일성/해시를 정의
extension OfficialPlaceItem: Hashable {
    static func == (lhs: OfficialPlaceItem, rhs: OfficialPlaceItem) -> Bool {
        return lhs.officialPlaceId == rhs.officialPlaceId
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(officialPlaceId)
    }
}

struct FavoriteTapPayload {
    let placeId: Int
    let placeType: FavoritePlaceType
    let isFavorite: Bool
    let indexPath: IndexPath
}

final class OfficialPlaceListViewController: UIViewController {
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
    enum Section { case main }

    let tableView = UITableView(frame: .zero, style: .plain)
    var onOfficialSelect: ((OfficialPlaceItem) -> Void)?
    var onUserSelect: ((UserPlaceItem) -> Void)?

    // 외부에서 헤더 타이틀 바꾸기
    func updateHeader(title: String) {
        headerLabel.text = title
        layoutHeader()
    }

    // 외부에서 데이터 적용
    func apply(places: [OfficialPlaceItem], animate: Bool = true) {
        officialItems = places
        var snapshot = NSDiffableDataSourceSnapshot<Section, OfficialPlaceItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(places, toSection: .main)
        officialDataSource.apply(snapshot, animatingDifferences: animate)
        emptyView.isHidden = !places.isEmpty
    }
    
    func applyFavoriteChange(placeId: Int, isFavorite: Bool) {
        // 1) 모델 업데이트
        guard let idx = officialItems.firstIndex(where: { $0.officialPlaceId == placeId }) else { return }
        officialItems[idx].isFavorite = isFavorite
        let item = officialItems[idx]

        // 2) 보이는 셀이면 버튼만 즉시 토글
        if let indexPath = officialDataSource.indexPath(for: item),
           let cell = tableView.cellForRow(at: indexPath) as? OfficialPlaceInfoCell {
            cell.setFavoriteSelected(isFavorite) // 셀에 헬퍼 추가
            // 끝. (스냅샷 적용 불필요)
        } else {
            // 3) 화면에 없으면 다음 표시를 위해 최소 갱신
            var snapshot = officialDataSource.snapshot()
            snapshot.reloadItems([item])            // iOS 15+면 reconfigureItems([item]) 권장
            officialDataSource.apply(snapshot, animatingDifferences: false)
        }
    }

    // MARK: Private
    private var officialItems: [OfficialPlaceItem] = []
    private lazy var officialDataSource = makeOfficialDataSource()

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
private extension OfficialPlaceListViewController {
    func configure() {
        view.backgroundColor = .clear

        // TableView
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = true
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(OfficialPlaceInfoCell.self, forCellReuseIdentifier: OfficialPlaceInfoCell.reuseID)
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
//            grabber.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: grabberTop),
//            grabber.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
//            grabber.widthAnchor.constraint(equalToConstant: 44),
//            grabber.heightAnchor.constraint(equalToConstant: 5),

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

    func makeOfficialDataSource() -> UITableViewDiffableDataSource<Section, OfficialPlaceItem> {
        let ds = UITableViewDiffableDataSource<Section, OfficialPlaceItem>(tableView: tableView) { [weak self] tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OfficialPlaceInfoCell.reuseID, for: indexPath) as? OfficialPlaceInfoCell else {
                return UITableViewCell(style: .default, reuseIdentifier: "fallback")
            }
            cell.configure(with: item)
            
            cell.onFavoriteTapped = { [weak self] in
                guard let self else { return }
                
                print("이름이 무엇 item : \(item.officialPlaceName)")
                
                let payload = FavoriteTapPayload(
                    placeId: item.officialPlaceId,
                    placeType: .OFFICIAL_PLACE,
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
extension OfficialPlaceListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let officialItem = officialDataSource.itemIdentifier(for: indexPath) {
            onOfficialSelect?(officialItem)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // 카드 사이 여백 조금 추가 (섹션 헤더/푸터 대신)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
