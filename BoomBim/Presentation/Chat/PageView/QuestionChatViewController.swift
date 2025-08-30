//
//  QuestionChatViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/22/25.
//

import UIKit
import RxSwift
import RxCocoa

final class QuestionChatViewController: UIViewController {
    private let viewModel: QuestionChatViewModel
    private let disposeBag = DisposeBag()
    
    private let endVoteRelay = PublishRelay<Int>()
    
    private var questions: [QuestionChatItem] = []
    private var filter: PollFilter = .all
    private var sort:   PollSort   = .latest
    
    var onNeedRefresh: (() -> Void)?
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
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
    
    init(viewModel: QuestionChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
//        // dummy Data
//        questions = [
//            .init(profileImage: [nil, nil, nil], people: 18, update: "5", title: "서울역", relaxed: 15, normal: 3, busy: 2, crowded: 3, isVoting: true),
//            .init(profileImage: [nil, nil], people: 38, update: "30", title: "신촌역", relaxed: 15, normal: 3, busy: 22, crowded: 36, isVoting: false),
//            .init(profileImage: [nil], people: 8, update: "45", title: "강남역", relaxed: 35, normal: 43, busy: 12, crowded: 3, isVoting: true),
//            .init(profileImage: [nil, nil, nil], people: 50, update: "55", title: "홍대입구역", relaxed: 15, normal: 3, busy: 52, crowded: 13, isVoting: false),
//        ]
        
        bind()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        if questions.isEmpty {
//            emptyStackView.isHidden = false
//            questionTableView.isHidden = true
//        } else {
//            emptyStackView.isHidden = true
//            questionTableView.isHidden = false
//        }
//    }
    
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
        questionTableView.delegate = nil
        questionTableView.dataSource = nil
        questionTableView.rx.setDelegate(self).disposed(by: disposeBag)
        
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
    
    private func bind() {
        let output = viewModel.transform(.init(endVoteTap: endVoteRelay.asSignal()))
        
        // 목록 바인딩(예시)
        output.items
            .drive(questionTableView.rx.items(cellIdentifier: QuestionChatCell.identifier, cellType: QuestionChatCell.self)) { [weak self] _, item, cell in
                print("item: \(item)")
                
                let questionChatItem: QuestionChatItem = .init(
                    profileImage: item.profile,
                    people: item.profile.count,
                    update: "1",
                    title: item.posName,
                    relaxed: item.relaxedCnt,
                    normal: item.commonly,
                    busy: item.slightlyBusyCnt,
                    crowded: item.crowedCnt,
                    isVoting: !item.voteFlag)
                
                cell.configure(questionChatItem)
                cell.onVote = {  selectedIndex in
                    
                    self?.confirmEnd(voteId: item.voteId)
                    print("selectedIndex : \(selectedIndex)")
                }

            }
            .disposed(by: disposeBag)
        
        // 로딩/토스트
        output.isLoading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        let isEmpty = output.items
            .map { $0.isEmpty }
            .distinctUntilChanged()
        
        Driver.combineLatest(output.isLoading, isEmpty) { isLoading, isEmpty -> (Bool, Bool) in
            (isLoading, isEmpty)
        }
        .drive(onNext: { [weak self] isLoading, isEmpty in
            guard let self = self else { return }
            if isLoading {
                self.questionTableView.isHidden = true
                self.emptyStackView.isHidden = true
            } else {
                self.questionTableView.isHidden = isEmpty
                self.emptyStackView.isHidden = !isEmpty
            }
        })
        .disposed(by: disposeBag)
        
//        output.toast
//            .emit(onNext: { [weak self] msg in self?.showToast(msg) })
//            .disposed(by: disposeBag)
        
        // 종료 성공 → 부모에게 목록 갱신 요청
        output.ended
            .emit(onNext: { [weak self] _ in self?.onNeedRefresh?() })
            .disposed(by: disposeBag)
    }
    
    private func confirmEnd(voteId: Int) {
        let ac = UIAlertController(title: "투표 종료", message: "이 투표를 종료할까요?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "취소", style: .cancel))
        ac.addAction(UIAlertAction(title: "종료", style: .destructive, handler: { [weak self] _ in
            self?.endVoteRelay.accept(voteId)  // ✅ VM으로 전달
        }))
        present(ac, animated: true)
    }
}

extension QuestionChatViewController: UITableViewDelegate/*, UITableViewDataSource*/ {
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
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let index = indexPath.row
//        let question = questions[index]
//        let cell = tableView.dequeueReusableCell(withIdentifier: QuestionChatCell.identifier, for: indexPath) as! QuestionChatCell
//        
//        cell.configure(question)
//        cell.onVote = { [weak self, weak cell, weak tableView] in
//            guard let self, let cell = cell, let tableView = tableView, let currentIndexPath = tableView.indexPath(for: cell)
//            else { return }
//            
//            print("vote Button Tapped : \(currentIndexPath.row)")
//            let dialog = ConfirmDialogController(
//                title: "투표를 종료할까요?",
//                message: "해당 장소 모든 투표가 종료됩니다.",
//                confirmTitle: "예",
//                cancelTitle: "아니요",
//                onConfirm: { [weak self] in
//                    // self?.viewModel.endPoll() // 실제 종료 호출
//                    // self.viewModel.sendVote(row: ip.row, optionIndex: option)
//                }
//            )
//            
//            present(dialog, animated: true)
//        }
//        
//        return cell
//    }
    
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
