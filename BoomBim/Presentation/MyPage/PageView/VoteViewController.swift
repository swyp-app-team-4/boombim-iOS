//
//  VoteViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/21/25.
//

import UIKit
import RxSwift
import RxCocoa

struct VoteRow {
    let day: String
    let info: AnswerInfo
}

final class VoteViewController: UIViewController {
    private let viewModel: VoteViewModel
    private let disposeBag = DisposeBag()
    
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
        imageView.image = .illustrationVote
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.medium.font
        label.textColor = .grayScale10
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "지금 있는 위치의\n혼잡도를 공유해보세요"
        
        return label
    }()
    
    private lazy var emptyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .main
        button.setTitle("혼잡도 알리기", for: .normal)
        button.setTitleColor(.grayScale1, for: .normal)
        button.titleLabel?.font = Typography.Body02.medium.font
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        
        return button
    }()
    
    private let voteTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        return tableView
    }()
    
    init(viewModel: VoteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        let rows: Driver<[VoteRow]> = viewModel.output.items
            .map { arr in
                arr.flatMap { mq in
                    mq.res.map {
                        VoteRow(day: mq.day, info: $0)
                    }
                }
            }
        
        rows.drive(voteTableView.rx.items(
                cellIdentifier: VoteQuestionCell.identifier,
                cellType: VoteQuestionCell.self
            )) { _, row, cell in
                
                let info = row.info
                let congestion = CongestionLevel.fromCounts(
                    relaxed: info.relaxedCnt,
                    normal:  info.commonly,
                    busy:    info.slightlyBusyCnt,
                    crowded: info.crowedCnt
                )
                
                let voteItem = VoteItem(
                    image: .dummy,
                    title: info.posName,
                    congestion: congestion,
                    people: info.voteAllCnt,
                    isVoting: info.voteStatus == VoteStatus.PROGRESS
                )
                
                cell.configure(voteItem)
            }
            .disposed(by: disposeBag)
        
        rows.map { !$0.isEmpty }
            .distinctUntilChanged()
            .drive(onNext: { [weak self] hasAny in
                guard let self else { return }
                self.emptyStackView.isHidden = hasAny
                self.voteTableView.isHidden = !hasAny
            })
            .disposed(by: disposeBag)
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
            emptyStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            emptyStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func configureTableView() {
        voteTableView.register(VoteQuestionCell.self, forCellReuseIdentifier: VoteQuestionCell.identifier)
        voteTableView.register(VoteQuestionHeaderView.self, forHeaderFooterViewReuseIdentifier: VoteQuestionHeaderView.identifier)
        
        voteTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(voteTableView)
        
        voteTableView.rx.setDelegate(self)
                .disposed(by: disposeBag)
        
        NSLayoutConstraint.activate([
            voteTableView.topAnchor.constraint(equalTo: view.topAnchor),
            voteTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            voteTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            voteTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension VoteViewController: UITableViewDelegate/*, UITableViewDataSource*/ {

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let index = indexPath.row
//        let notice = votes[index]
//        let cell = tableView.dequeueReusableCell(withIdentifier: VoteQuestionCell.identifier, for: indexPath) as! VoteQuestionCell
//        
//        cell.configure(notice)
//        
//        return cell
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: VoteQuestionHeaderView.identifier) as! VoteQuestionHeaderView
        header.configure(date: "2025.05.01")
        
        return header
    }
}
