//
//  AlarmSettingViewController.swift
//  BoomBim
//
//  Created by 조영현 on 10/21/25.
//

import UIKit

final class AlarmSettingViewController: BaseViewController {
    private let viewModel: AlarmSettingViewModel
    private var switchOn: Bool = false

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        return tableView
    }()

    init(viewModel: AlarmSettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "알림"
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
        viewModel.loadInitialState()              // 초기 상태 로드
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.appDidBecomeActive()            // 설정에서 복귀 시 동기화
    }

    private func setupView() {
        view.backgroundColor = .background
        navigationController?.navigationBar.tintColor = .grayScale9

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.register(AlarmSettingCell.self, forCellReuseIdentifier: AlarmSettingCell.identifier)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: CGFloat.leastNonzeroMagnitude))

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] on in
            self?.switchOn = on
            self?.tableView.reloadData()
        }
        viewModel.onNeedOpenSettings = { [weak self] in
            self?.presentGoToSettingsAlert()
        }
        viewModel.onError = { [weak self] msg in
            self?.presentErrorAlert(msg)
        }
    }

    private func presentGoToSettingsAlert() {
        let alert = UIAlertController(
            title: "알림을 사용할 수 없어요",
            message: "설정 > 알림에서 이 앱의 알림을 허용해 주세요.",
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "취소", style: .cancel))
        alert.addAction(.init(title: "설정 열기", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }))
        present(alert, animated: true)
    }

    private func presentErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "안내", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

extension AlarmSettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: AlarmSettingCell.identifier,
            for: indexPath
        ) as! AlarmSettingCell

        cell.backgroundColor = .clear
        cell.selectionStyle = .none

        cell.configure(
            title: "alarmSetting.label.state".localized(),
            isOn: switchOn,
            onToggle: { [weak self] newValue in
                self?.viewModel.handleToggle(newValue)
            }
        )
        return cell
    }
}
