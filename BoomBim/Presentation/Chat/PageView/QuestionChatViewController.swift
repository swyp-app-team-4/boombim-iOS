//
//  QuestionChatViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/22/25.
//

import UIKit

final class QuestionChatViewController: UIViewController {
    
    private var questions: [QuestionChatItem] = []
    private var filter: PollFilter = .all
    private var sort:   PollSort   = .latest
    
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
    
    private let questionTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .tableViewBackground
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        // dummy Data
        questions = [
            .init(profileImage: [nil, nil, nil], people: 18, update: "5", title: "서울역", relaxed: 15, normal: 3, busy: 2, crowded: 3, isVoting: true),
            .init(profileImage: [nil, nil], people: 38, update: "30", title: "신촌역", relaxed: 15, normal: 3, busy: 22, crowded: 36, isVoting: false),
            .init(profileImage: [nil], people: 8, update: "45", title: "강남역", relaxed: 35, normal: 43, busy: 12, crowded: 3, isVoting: true),
            .init(profileImage: [nil, nil, nil], people: 50, update: "55", title: "홍대입구역", relaxed: 15, normal: 3, busy: 52, crowded: 13, isVoting: false),
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if questions.isEmpty {
            emptyStackView.isHidden = false
            questionTableView.isHidden = true
        } else {
            emptyStackView.isHidden = true
            questionTableView.isHidden = false
        }
    }
    
    private func setupView() {
        view.backgroundColor = .tableViewBackground
        
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
        questionTableView.delegate = self
        questionTableView.dataSource = self
        questionTableView.register(QuestionChatCell.self, forCellReuseIdentifier: QuestionChatCell.identifier)
        questionTableView.register(PollListSectionHeader.self, forHeaderFooterViewReuseIdentifier: PollListSectionHeader.identifier)
        
        questionTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(questionTableView)
        
        NSLayoutConstraint.activate([
            questionTableView.topAnchor.constraint(equalTo: view.topAnchor),
            questionTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            questionTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            questionTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension QuestionChatViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        questions.count
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let question = questions[index]
        let cell = tableView.dequeueReusableCell(withIdentifier: QuestionChatCell.identifier, for: indexPath) as! QuestionChatCell
        
        cell.configure(question)
        cell.onVote = { [weak self, weak cell, weak tableView] in
            guard let self, let cell = cell, let tableView = tableView, let currentIndexPath = tableView.indexPath(for: cell)
            else { return }
            
            print("vote Button Tapped : \(currentIndexPath.row)")
//            self.viewModel.sendVote(row: ip.row, optionIndex: option)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: PollListSectionHeader.identifier) as! PollListSectionHeader
        
        header.configure(filter: filter, sort: sort, onFilter: { [weak self] filter in
            self?.filter = filter
            self?.applyFilterAndReload()
        }, onSort: { [weak self] sort in
            self?.sort = sort
            self?.applyFilterAndReload()
        })
        return header
    }
    
    private func applyFilterAndReload() {
        print("filter : \(filter)")
        print("sort : \(sort)")
        questionTableView.reloadData()
    }
}
