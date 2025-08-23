//
//  VoteChatViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/22/25.
//

import UIKit

final class VoteChatViewController: UIViewController {
    
    private var votes: [VoteChatItem] = []
    
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
        tableView.backgroundColor = .tableViewBackground
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        // dummy Data
        votes = [
            .init(profileImage: [], people: 10, update: "5", title: "서울역", roadImage: nil, congestion: .relaxed, isVoting: true),
            .init(profileImage: [], people: 13, update: "15", title: "강남역", roadImage: nil, congestion: .busy, isVoting: false),
            .init(profileImage: [], people: 6, update: "25", title: "신촌역", roadImage: nil, congestion: .relaxed, isVoting: true),
            .init(profileImage: [], people: 9, update: "35", title: "양재역", roadImage: nil, congestion: .crowded, isVoting: false),
            .init(profileImage: [], people: 11, update: "55", title: "건대입구역", roadImage: nil, congestion: .normal, isVoting: true)
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
        voteTableView.delegate = self
        voteTableView.dataSource = self
        voteTableView.register(VoteChatCell.self, forCellReuseIdentifier: VoteChatCell.identifier)
        
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

extension VoteChatViewController: UITableViewDelegate, UITableViewDataSource {
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
        let vote = votes[index]
        let cell = tableView.dequeueReusableCell(withIdentifier: VoteChatCell.identifier, for: indexPath) as! VoteChatCell
        
        cell.configure(vote)
        cell.onVote = { [weak self, weak tableView] selectedIndex in
            guard let self, let tableView, let currentIndexPath = tableView.indexPath(for: cell) // 재사용 대비, 최신 indexPath 구하기
            else { return }
            
            print("vote Button Tapped : \(currentIndexPath.row)")
            print("selectedIndex : \(selectedIndex)")
        }
        
        return cell
    }
}

