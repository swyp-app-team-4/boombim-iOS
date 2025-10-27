//
//  PersonalInfoViewController.swift
//  BoomBim
//
//  Created by 조영현 on 10/21/25.
//

import UIKit

final class PersonalInfoViewController: BaseViewController {
    private let viewModel: PersonalInfoViewModel
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        
        return tableView
    }()
    
    init(viewModel: PersonalInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        self.title = "개인정보 관리"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .background
        
        setupNavigationBar()
        configureTableView()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .grayScale9
    }
    
    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none

        tableView.register(PersonalInfoCell.self, forCellReuseIdentifier: PersonalInfoCell.identifier)
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: CGFloat.leastNonzeroMagnitude))
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension PersonalInfoViewController: UITableViewDataSource {
    // MARK: - DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PersonalInfoCell.identifier, for: indexPath) as! PersonalInfoCell
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.configure(title: "personalInfo.label.connection".localized(), state: viewModel.currentLoginState)
        
        return cell
    }
}

