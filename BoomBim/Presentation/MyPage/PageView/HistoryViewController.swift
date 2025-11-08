//
//  HistoryViewController.swift
//  BoomBim
//
//  Created by 조영현 on 11/7/25.
//

import UIKit
import RxSwift
import RxCocoa

final class HistoryViewController: UIViewController {
    private let viewModel: HistoryViewModel
    private let disposeBag = DisposeBag()
    
    // 섹션 모델
    private struct Section {
        let day: Date                  // KST 기준 하루(0시)
        var rows: [Row]
    }
    private struct Row {
        let title: String              // posName
        let level: String              // congestionLevel
        let date: Date                 // createdAt 파싱된 Date
    }
    
    private var sections: [Section] = []
    
    // UI
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
        imageView.image = .illustrationVote
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayScale10
        label.textAlignment = .center
        label.numberOfLines = 0
        label.setText("지금 있는 위치의\n혼잡도를 공유해보세요", style: Typography.Body02.medium)
        
        return label
    }()
    
    private lazy var emptyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .main
        button.setTitle("혼잡도 질문하기", for: .normal)
        button.setTitleColor(.grayScale1, for: .normal)
        button.titleLabel?.font = Typography.Body02.medium.font
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        
        return button
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 86
        tv.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.reuseID)
        return tv
    }()
    
    // MARK: - Init
    init(viewModel: HistoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }
    
    private func setupView() {
        view.backgroundColor = .background
        
        configureEmptyStackView()
        configureTableView()
    }
    
    private func configureEmptyStackView() {
        [emptyIllustrationImageView, emptyTitleLabel, emptyButton].forEach { view in
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
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.dataSource = self
        tableView.delegate   = self
    }
    
    // MARK: - Bind
    private func bind() {
        viewModel.output.items
            .map { [weak self] list in
                self?.buildSections(from: list) ?? []
            }
            .drive(onNext: { [weak self] secs in
                guard let self else { return }
                let empty: Bool = secs.isEmpty
                
                self.emptyStackView.isHidden = !empty
                self.tableView.isHidden = empty
                
                self.sections = secs
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func buildSections(from list: [MyHistory]) -> [Section] {
        // 1) DTO -> Row (Date 파싱)
        let rows: [Row] = list.compactMap { dto in
            guard let d = DateHelper.parseServerDate(dto.createdAt) else { return nil }
            return Row(title: dto.posName, level: dto.congestionLevel, date: d)
        }
        // 2) 날짜별(KST) 그룹핑
        let grouped = Dictionary(grouping: rows, by: { DateHelper.startOfDayKST(for: $0.date) })
        
        // 3) 섹션/행 정렬 (날짜 내림, 시간 내림)
        return grouped
            .map { Section(day: $0.key, rows: $0.value.sorted(by: { $0.date > $1.date })) }
            .sorted(by: { $0.day > $1.day })
    }
}

// MARK: - UITableViewDataSource / Delegate
extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { sections.count }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { sections[section].rows.count }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryCell.reuseID, for: indexPath) as! HistoryCell
        let row = sections[indexPath.section].rows[indexPath.row]
        cell.apply(
            title: row.title,
            timeText: DateHelper.formatTimeKST(row.date),
            level: row.level
        )
        
        return cell
    }
    
    // 섹션 헤더(예: "2025. 08. 14 (목)")
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        let label = UILabel()
        label.textColor = .grayScale9
        label.setText(DateHelper.formatHeaderKST(sections[section].day), style: Typography.Body01.semiBold)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: v.topAnchor, constant: 22),
            label.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -12),
            label.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(lessThanOrEqualTo: v.trailingAnchor, constant: -16)
        ])
        return v
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 58 }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { 20 } // Cell 하단 공백을 뺀 값
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section != sections.count - 1 else { return nil }
        
        let v = UIView()
        v.backgroundColor = .clear
        let dividerView = UIView()
        dividerView.backgroundColor = .tableViewDivider
        
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(dividerView)
        
        NSLayoutConstraint.activate([
            dividerView.topAnchor.constraint(equalTo: v.topAnchor, constant: 12),
            dividerView.bottomAnchor.constraint(equalTo: v.bottomAnchor),
            dividerView.leadingAnchor.constraint(equalTo: v.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: v.trailingAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 8)
        ])
        
        return v
    }
}
