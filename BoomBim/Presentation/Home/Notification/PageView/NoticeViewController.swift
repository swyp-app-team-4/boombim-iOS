//
//  NoticeViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/20/25.
//

import UIKit

final class NoticeViewController: UIViewController {
    
    private var notices: [NoticeItem] = []
    
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
        imageView.image = .illustrationNotification
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.medium.font
        label.textColor = .grayScale10
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "notification.empty.label".localized()
        
        return label
    }()
    
    private lazy var emptyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .main
        button.setTitle("norification.empty.button".localized(), for: .normal)
        button.setTitleColor(.grayScale1, for: .normal)
        button.titleLabel?.font = Typography.Body02.medium.font
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        
        return button
    }()
    
    private let noticeTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupActions()
        
        // dummy Data
        notices = [
            .init(image: .dummy, title: "붐빔 알림) 새로운 업데이트가 있습니다!", date: "2025.08.20"),
            .init(image: .dummy, title: "붐빔 알림) 새로운 업데이트가 있습니다!", date: "2025.08.16"),
            .init(image: .dummy, title: "붐빔 알림) 새로운 업데이트가 있습니다!", date: "2025.08.10")
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if notices.isEmpty {
            emptyStackView.isHidden = false
            noticeTableView.isHidden = true
        } else {
            emptyStackView.isHidden = true
            noticeTableView.isHidden = false
        }
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
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
            emptyButton.heightAnchor.constraint(equalToConstant: 44),
            
            emptyStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            emptyStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func configureTableView() {
        noticeTableView.delegate = self
        noticeTableView.dataSource = self
        noticeTableView.register(NoticeTableViewCell.self, forCellReuseIdentifier: NoticeTableViewCell.identifier)
        
        noticeTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noticeTableView)
        
        NSLayoutConstraint.activate([
            noticeTableView.topAnchor.constraint(equalTo: view.topAnchor),
            noticeTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            noticeTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            noticeTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupActions() {
        setupEmptyButtonAction()
    }
    
    private func setupEmptyButtonAction() {
        emptyButton.addTarget(self, action: #selector(emptyButtonTapped), for: .touchUpInside)
    }
    
    @objc private func emptyButtonTapped() {
        print("empty Button Tapped")
    }
}

extension NoticeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notices.count
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let notice = notices[index]
        let cell = tableView.dequeueReusableCell(withIdentifier: NoticeTableViewCell.identifier, for: indexPath) as! NoticeTableViewCell
        
        cell.configure(notice)
        
        return cell
    }
}
