//
//  PointViewController.swift
//  BoomBim
//
//  Created by 조영현 on 11/3/25.
//

import UIKit
import RxSwift

final class PointViewController: BaseViewController {
    private let viewModel: PointViewModel
    // Expected ViewModel API (adjust to your actual implementation):
    // var onTapEvent: (() -> Void)?
    // var onTapPoint: (() -> Void)?
    private let disposeBag = DisposeBag()
    
    private var items: [PointHistoryItem] = []
    
    private let headerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .grayScale1
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.shadow.cgColor
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 4
        
        return view
    }()
    
    private let headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 12
        
        return stackView
    }()
    
    private let pointContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .grayScale1
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.shadow.cgColor
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 4
        
        return view
    }()
    
    private let pointStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 2
        
        return stackView
    }()
    
    private let pointTitleLabel: UILabel = {
        let label = UILabel()
        label.setText("보유 포인트", style: Typography.Body03.medium)
        label.textColor = .grayScale8
        
        return label
    }()
    
    private let pointValueLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        return stackView
    }()
    
    private let eventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("이벤트 응모하기", for: .normal)
        button.titleLabel?.font = Typography.Body03.medium.font
        button.setTitleColor(.main, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.main.cgColor
        
        return button
    }()
    
    private let pointButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("포인트 모으기", for: .normal)
        button.titleLabel?.font = Typography.Body03.medium.font
        button.setTitleColor(.main, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.main.cgColor
        
        return button
    }()
    
    private let filterBar = PointFilterBarView()
    
    public let tableView = UITableView(frame: .zero, style: .plain)
    
    init(viewModel: PointViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        self.title = "포인트 내역"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        bind()
        
        setActions()
    }
    
    private func setupView() {
        view.backgroundColor = .background
        
        configureHeader()
        configureFilter()
        configureTableView()
    }
    
    private func configureHeader() {
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(headerContainerView)
        
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.addSubview(headerStackView)
        
        [pointContainerView, buttonStackView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            headerStackView.addArrangedSubview(view)
        }
        
        pointStackView.translatesAutoresizingMaskIntoConstraints = false
        pointContainerView.addSubview(pointStackView)
        
        [pointTitleLabel, pointValueLabel].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            pointStackView.addArrangedSubview(label)
        }
        
        [eventButton, pointButton].forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            buttonStackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            headerContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            headerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            headerStackView.topAnchor.constraint(equalTo: headerContainerView.topAnchor, constant: 14),
            headerStackView.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: -14),
            headerStackView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 14),
            headerStackView.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: -14),
            
            pointStackView.topAnchor.constraint(equalTo: pointContainerView.topAnchor, constant: 12),
            pointStackView.bottomAnchor.constraint(equalTo: pointContainerView.bottomAnchor, constant: -12),
            pointStackView.leadingAnchor.constraint(equalTo: pointContainerView.leadingAnchor, constant: 12),
            pointStackView.trailingAnchor.constraint(equalTo: pointContainerView.trailingAnchor, constant: -12),
            
            eventButton.heightAnchor.constraint(equalToConstant: 42),
            pointButton.heightAnchor.constraint(equalToConstant: 42),
        ])
    }
    
    private func configureFilter() {
        filterBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterBar)
        
        NSLayoutConstraint.activate([
            filterBar.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: 22),
            filterBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func configureTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 82
        
        tableView.register(PointHistoryCell.self, forCellReuseIdentifier: PointHistoryCell.identifier)
        tableView.dataSource = self
        tableView.delegate   = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: filterBar.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - bind
    private func bind() {
        viewModel.pointRelay
            .asDriver()
            .drive(onNext: { [weak self] point in
                print("point : \(point.point)")
                print("pointHistory : \(point.getPointHistoryRes)")
                self?.applyPointHistory(point: point)
            })
            .disposed(by: disposeBag)
    }
    
    private func applyPointHistory(point: UserPoint) {
        pointValueLabel.setPoints(point.point, numberStyle: Typography.Heading02.semiBold, numberColor: .main, suffixStyle: Typography.Heading02.semiBold, suffixColor: .grayScale7)
        
        self.items = mapHistory(point.getPointHistoryRes)
        print("items.count : \(self.items.count)")
        tableView.reloadData()
    }
    
    // MARK: - Actions
    private func setActions() {
        eventButton.addTarget(self, action: #selector(didTapEventButton), for: .touchUpInside)
        pointButton.addTarget(self, action: #selector(didTapPointButton), for: .touchUpInside)
    }
    
    @objc private func didTapEventButton() {
        viewModel.goToEventInfoView?()
    }

    @objc private func didTapPointButton() {
        viewModel.goToCongestionReportView?()
    }
}

extension PointViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PointHistoryCell.identifier, for: indexPath) as! PointHistoryCell
        let index = indexPath.row
        let showDate: Bool
        
        if index == 0 {
            showDate = true
        } else {
            let prev = items[index - 1]
            showDate = !Calendar.current.isDate(items[index].date, inSameDayAs: prev.date)
        }
        cell.configure(items[index], showDate: showDate)
        
        return cell
    }
    
    /// 서버의 PointHistory 배열 -> 셀 모델 배열로 변환
    func mapHistory(_ histories: [PointHistory]) -> [PointHistoryItem] {
        let parsed: [PointHistoryItem] = histories.compactMap { h in
            let date = DateHelper.parseServerDate(h.createdAt) ?? Date()
            let isEarn = h.pointAction.uppercased() == "EARN"
            let delta = isEarn ? +h.amount : -h.amount
            
            return PointHistoryItem(
                date: date,
                title: h.pointCategory,
                delta: delta,
                balance: h.balance
            )
        }
        
        // 최신순(내림차순) 정렬
        return parsed.sorted { $0.date > $1.date }
    }
    
    private static func makeDate(_ s: String) -> Date {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.calendar = Calendar(identifier: .gregorian)
        f.timeZone = TimeZone(secondsFromGMT: 0)              // 서버가 UTC라면
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"  
        
        guard let date = f.date(from: s) else {
            print("설마?")
            return Date()
        }
        
        return f.date(from: s) ?? Date()
    }
}
