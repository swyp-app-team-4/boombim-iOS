//
//  SettingsViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/11/25.
//

import UIKit

final class SettingsViewController: BaseViewController {
    private let viewModel: SettingsViewModel

    private let rows = SettingsRow.allCases
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .white
        
        return tableView
    }()
    
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "설정"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        setupNavigationBar()
        configureTableView()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .grayScale9
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        
        tableView.separatorStyle = .none

        tableView.register(SettingCell.self, forCellReuseIdentifier: SettingCell.identifier)
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: CGFloat.leastNonzeroMagnitude))
        
        tableView.tableFooterView = makeFooter() // 하단 “로그아웃/회원 탈퇴”
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func tapLogout() {
        print("logout tapped")
    }
    
    @objc private func tapWithdraw() {
        print("withdraw tapped")
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.identifier, for: indexPath) as! SettingCell
        
        let index = indexPath.row
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.configure(title: rows[index].title)
        
        return cell
    }

    // MARK: - Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // TODO: 각각의 화면 이동
    }

    // MARK: - Footer
    private func makeFooter() -> UIView {
        let container = UIView()
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        let logout = UIButton(type: .system)
        logout.setTitle("settings.button.logout".localized(), for: .normal)
        logout.setTitleColor(.grayScale7, for: .normal)
        logout.titleLabel?.font = Typography.Body03.regular.font
        logout.addTarget(self, action: #selector(tapLogout), for: .touchUpInside)

        let withdraw = UIButton(type: .system)
        withdraw.setTitle("settings.button.withdraw".localized(), for: .normal)
        withdraw.titleLabel?.font = Typography.Body03.regular.font
        withdraw.setTitleColor(.grayScale7, for: .normal)
        withdraw.addTarget(self, action: #selector(tapWithdraw), for: .touchUpInside)

        stack.addArrangedSubview(logout)
        stack.addArrangedSubview(withdraw)

        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            stack.heightAnchor.constraint(equalToConstant: 50)
        ])

        container.frame = CGRect(x: 0, y: 0, width: 0, height: 74)
        
        return container
    }
}
