//
//  VoteViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/21/25.
//

import UIKit

final class VoteViewController: UIViewController {
    
    private var votes: [VoteItem] = []
    
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
        label.text = "질문이 없습니다"
        
        return label
    }()
    
    private let voteTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        // dummy Data
        votes = [
            .init(image: .dummy, title: "강남역", congestion: .relaxed, people: 5, isVoting: true),
            .init(image: .dummy, title: "신촌역", congestion: .normal, people: 15, isVoting: false),
            .init(image: .dummy, title: "코엑스", congestion: .busy, people: 30, isVoting: false),
            .init(image: .dummy, title: "서울역", congestion: .crowded, people: 42, isVoting: false)
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if votes.isEmpty {
            emptyStackView.isHidden = false
            voteTableView.isHidden = true
        } else {
            emptyStackView.isHidden = true
            voteTableView.isHidden = false
        }
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        configureEmptyStackView()
        configureTableView()
    }
    
    private func configureEmptyStackView() {
        [emptyIllustrationImageView, emptyTitleLabel].forEach { view in
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
        voteTableView.delegate = self
        voteTableView.dataSource = self
        voteTableView.register(VoteQuestionCell.self, forCellReuseIdentifier: VoteQuestionCell.identifier)
        voteTableView.register(VoteQuestionHeaderView.self, forHeaderFooterViewReuseIdentifier: VoteQuestionHeaderView.identifier)
        
        voteTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(voteTableView)
        
        NSLayoutConstraint.activate([
            voteTableView.topAnchor.constraint(equalTo: view.topAnchor),
            voteTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            voteTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            voteTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension VoteViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        votes.count
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let notice = votes[index]
        let cell = tableView.dequeueReusableCell(withIdentifier: VoteQuestionCell.identifier, for: indexPath) as! VoteQuestionCell
        
        cell.configure(notice)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: VoteQuestionHeaderView.identifier) as! VoteQuestionHeaderView
        header.configure(date: "2025.05.01")
        
        return header
    }
}
