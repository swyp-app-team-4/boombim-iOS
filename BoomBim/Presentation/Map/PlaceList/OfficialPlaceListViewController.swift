//
//  PlaceListViewController.swift
//  BoomBim
//
//  Created by 조영현 on 9/1/25.
//

import UIKit

// 고유 id로만 동일성/해시를 정의
extension OfficialPlaceItem: Hashable {
    static func == (lhs: OfficialPlaceItem, rhs: OfficialPlaceItem) -> Bool {
        return lhs.officialPlaceId == rhs.officialPlaceId
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(officialPlaceId)
    }
}

extension UserPlaceItem: Hashable {
    static func == (lhs: UserPlaceItem, rhs: UserPlaceItem) -> Bool {
        return lhs.memberPlaceId == rhs.memberPlaceId
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(memberPlaceId)
    }
}

final class OfficialPlaceListViewController: UIViewController {
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

    // 외부에서 데이터 적용
    func apply(places: [OfficialPlaceItem], animate: Bool = true) {
        officialItems = places
        var snapshot = NSDiffableDataSourceSnapshot<Section, OfficialPlaceItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(places, toSection: .main)
        officialDataSource.apply(snapshot, animatingDifferences: animate)
        emptyView.isHidden = !places.isEmpty
    }
    
    func apply(places: [UserPlaceItem], animate: Bool = true) {
        userItems = places
        var snapshot = NSDiffableDataSourceSnapshot<Section, UserPlaceItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(places, toSection: .main)
        userDataSource.apply(snapshot, animatingDifferences: animate)
        emptyView.isHidden = !places.isEmpty
    }

    // 선택 항목 강조(목록 상태 유지)
//    func highlight(id: String) {
//        guard let idx = items.firstIndex(where: { String($0.id) == id }) else { return }
//        let ip = IndexPath(row: idx, section: 0)
//        tableView.scrollToRow(at: ip, at: .middle, animated: true)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
//            if let cell = self.tableView.cellForRow(at: ip) {
//                UIView.animate(withDuration: 0.22, animations: {
//                    cell.contentView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.14)
//                }) { _ in
//                    UIView.animate(withDuration: 0.35, delay: 0.5) {
//                        cell.contentView.backgroundColor = .clear
//                    }
//                }
//            }
//        }
//    }

    // MARK: Private
    private var officialItems: [OfficialPlaceItem] = []
    private var userItems: [UserPlaceItem] = []
    private lazy var officialDataSource = makeOfficialDataSource()
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
            return cell
        }
        return ds
    }
    
    func makeUserDataSource() -> UITableViewDiffableDataSource<Section, UserPlaceItem> {
        let ds = UITableViewDiffableDataSource<Section, UserPlaceItem>(tableView: tableView) { [weak self] tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OfficialPlaceInfoCell.reuseID, for: indexPath) as? OfficialPlaceInfoCell else {
                return UITableViewCell(style: .default, reuseIdentifier: "fallback")
            }
            cell.configure(with: item)
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
        } else if let userItem = userDataSource.itemIdentifier(for: indexPath) {
            onUserSelect?(userItem)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // 카드 사이 여백 조금 추가 (섹션 헤더/푸터 대신)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
