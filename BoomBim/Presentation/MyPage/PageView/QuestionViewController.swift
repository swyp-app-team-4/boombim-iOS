//
//  QuestionViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/21/25.
//

import UIKit
import RxSwift
import RxCocoa

struct QuestionRow {
    let day: String
    let info: QuestionInfo
}

final class QuestionViewController: BaseViewController {
    private let viewModel: QuestionViewModel
    private let disposeBag = DisposeBag()
    
    private var questions: [QuestionItem] = []
    
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
        tableView.backgroundColor = .clear
        
        return tableView
    }()
    
    init(viewModel: QuestionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        let rows: Driver<[QuestionRow]> = viewModel.output.items
            .map { arr in
                arr.flatMap { mq in
                    mq.res.map {
                        QuestionRow(day: mq.day, info: $0)
                    }
                }
            }
        rows.drive(questionTableView.rx.items(
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
                
                let questionItem = QuestionItem(
                    image: .dummy,
                    title: info.posName,
                    congestion: congestion,
                    people: info.voteAllCnt,
                    isQuesting: info.voteStatus == VoteStatus.PROGRESS
                )
                cell.configure(questionItem)
            }
            .disposed(by: disposeBag)
        
        rows.map { !$0.isEmpty }
            .distinctUntilChanged()
            .drive(onNext: { [weak self] hasAny in
                guard let self else { return }
                self.emptyStackView.isHidden = hasAny
                self.questionTableView.isHidden = !hasAny
            })
            .disposed(by: disposeBag)
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
        questionTableView.register(VoteQuestionCell.self, forCellReuseIdentifier: VoteQuestionCell.identifier)
        questionTableView.register(VoteQuestionHeaderView.self, forHeaderFooterViewReuseIdentifier: VoteQuestionHeaderView.identifier)
        
        questionTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(questionTableView)
        
        questionTableView.rx.setDelegate(self)
                .disposed(by: disposeBag)
        
        NSLayoutConstraint.activate([
            questionTableView.topAnchor.constraint(equalTo: view.topAnchor),
            questionTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            questionTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            questionTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension QuestionViewController: UITableViewDelegate/*, UITableViewDataSource*/ {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        questions.count
//    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let index = indexPath.row
//        let notice = questions[index]
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
