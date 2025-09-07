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
    
    private var sections: [(day: String, rows: [QuestionRow])] = []
    private var expandedIDs = Set<Int>()   // 어떤 카드가 펼쳐졌는지 저장
    
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
        imageView.image = .illustrationAskQuestion
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.medium.font
        label.textColor = .grayScale10
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "궁금한 장소의 투표를 올려보세요"
        
        return label
    }()
    
    private lazy var emptyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .main
        button.setTitle("혼잡도 질문하기", for: .normal)
        button.setTitleColor(.grayScale1, for: .normal)
        button.titleLabel?.font = Typography.Body02.medium.font
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        
        return button
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
        
//        rows.drive(questionTableView.rx.items(
//                cellIdentifier: VoteQuestionCell.identifier,
//                cellType: VoteQuestionCell.self
//            )) { _, row, cell in
//                
//                let info = row.info
//                let congestion = CongestionLevel.fromCounts(
//                    relaxed: info.relaxedCnt,
//                    normal:  info.commonly,
//                    busy:    info.slightlyBusyCnt,
//                    crowded: info.crowedCnt
//                )
//                
//                let questionItem = QuestionItem(
//                    image: .dummy,
//                    title: info.posName,
//                    congestion: congestion,
//                    people: info.voteAllCnt,
//                    isQuesting: info.voteStatus == VoteStatus.PROGRESS
//                )
//                cell.configure(questionItem)
//            }
//            .disposed(by: disposeBag)
//        
//        rows.map { !$0.isEmpty }
//            .distinctUntilChanged()
//            .drive(onNext: { [weak self] hasAny in
//                guard let self else { return }
//                self.emptyStackView.isHidden = hasAny
//                self.questionTableView.isHidden = !hasAny
//            })
//            .disposed(by: disposeBag)
        
        // 🔧 REPLACE: 셀 바인딩 부분 전부 교체
        // [VoteRow] -> 섹션 배열로 그룹핑/정렬
        let sectionsDriver: Driver<[(day: String, rows: [QuestionRow])]> = rows
            .map { rows in
                let grouped = Dictionary(grouping: rows, by: { $0.day })
                // day가 "yyyy.MM.dd" 포맷이라면 문자열 내림차순으로 최신이 위
                let orderedDays = grouped.keys.sorted(by: >)
                return orderedDays.map { (day: $0, rows: grouped[$0] ?? []) }
            }
        
        // 테이블에 반영
        sectionsDriver
            .drive(onNext: { [weak self] secs in
                self?.sections = secs
                self?.questionTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        // 빈 화면 토글도 섹션 기준으로
        sectionsDriver
            .map { !$0.isEmpty }
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
        questionTableView.register(VoteQuestionCell.self, forCellReuseIdentifier: VoteQuestionCell.identifier)
        questionTableView.register(VoteQuestionHeaderView.self, forHeaderFooterViewReuseIdentifier: VoteQuestionHeaderView.identifier)
        
        questionTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(questionTableView)
        
        questionTableView.dataSource = self
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

extension QuestionViewController: UITableViewDataSource, UITableViewDelegate {
    // 섹션 개수
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    // 섹션별 행 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }

    // 셀 구성
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: VoteQuestionCell.identifier,
            for: indexPath
        ) as! VoteQuestionCell

        let row = sections[indexPath.section].rows[indexPath.row]
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
            relaxedCnt: info.relaxedCnt,
            commonly: info.commonly,
            slightlyBusyCnt: info.slightlyBusyCnt,
            crowedCnt: info.crowedCnt,
            people: info.voteAllCnt,
            isQuesting: info.voteStatus == VoteStatus.PROGRESS
        )
        cell.configure(questionItem)
        cell.setExpanded(expandedIDs.contains(info.voteId), animated: false)
        
        cell.onToggle = { [weak self, weak tableView, weak cell] in
            guard let self, let tableView, let cell else { return }
            if self.expandedIDs.contains(info.voteId) {
                self.expandedIDs.remove(info.voteId)
            } else {
                self.expandedIDs.insert(info.voteId)
            }
            
            tableView.beginUpdates()
            cell.setExpanded(self.expandedIDs.contains(info.voteId), animated: true)
            tableView.endUpdates()
        }
        
        return cell
    }

    // 헤더(✅ day 표시)
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: VoteQuestionHeaderView.identifier
        ) as! VoteQuestionHeaderView
        header.configure(date: DateHelper.koreanFullDate(sections[section].day))
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        16
    }
}

//extension QuestionViewController: UITableViewDelegate/*, UITableViewDataSource*/ {
////    func numberOfSections(in tableView: UITableView) -> Int {
////        return 1
////    }
////    
////    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////        questions.count
////    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 16
//    }
//    
////    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
////        return UITableView.automaticDimension
////    }
////    
////    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////        let index = indexPath.row
////        let notice = questions[index]
////        let cell = tableView.dequeueReusableCell(withIdentifier: VoteQuestionCell.identifier, for: indexPath) as! VoteQuestionCell
////        
////        cell.configure(notice)
////        
////        return cell
////    }
//    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: VoteQuestionHeaderView.identifier) as! VoteQuestionHeaderView
//        header.configure(date: "2025.05.01")
//        
//        return header
//    }
//}
