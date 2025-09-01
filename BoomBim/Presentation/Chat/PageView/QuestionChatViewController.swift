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
    private let filterRelay = BehaviorRelay<PollFilter>(value: .all)
    private let sortRelay   = BehaviorRelay<PollSort>(value: .latest)
    
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
        
        bind()
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

        // ① items + filterRelay → filteredItems
        let filteredItems: Driver<[MyVoteItemResponse]> = Driver
            .combineLatest(output.items, filterRelay.asDriver())
        { items, filter in
            switch filter {
            case .all:
                return items
            case .ongoing:
                // 요구사항: voteFlag == true 만
                return items.filter { $0.voteFlag == true }
            case .closed:
                // 요구사항: voteFlag == false 만
                return items.filter { $0.voteFlag == false }
            }
        }

        // ② 테이블 바인딩: output.items → filteredItems 로 변경
        filteredItems
            .drive(questionTableView.rx.items(
                cellIdentifier: QuestionChatCell.identifier,
                cellType: QuestionChatCell.self
            )) { [weak self] _, item, cell in

                let questionChatItem: QuestionChatItem = .init(
                    profileImage: item.profile,
                    people: item.profile.count,
                    update: "1", // TODO: createdAt → 'n분 전'
                    title: item.posName,
                    relaxed: item.relaxedCnt,
                    normal: item.commonly,
                    busy: item.slightlyBusyCnt,
                    crowded: item.crowedCnt,
                    isVoting: item.voteFlag // 현재 로직 유지
                )

                cell.configure(questionChatItem)
                cell.onVote = { [weak self] selectedIndex in
                    self?.confirmEnd(voteId: item.voteId)
                }
            }
            .disposed(by: disposeBag)

        // ③ 로딩 인디케이터는 그대로
        output.isLoading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)

        // ④ 빈 상태 처리도 filteredItems 기준으로
        Driver.combineLatest(
            output.isLoading,
            filteredItems.map { $0.isEmpty }.distinctUntilChanged()
        )
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

        // 종료 성공 → 부모에게 목록 갱신 요청(기존 유지)
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: PollListSectionHeader.identifier) as! PollListSectionHeader
        
        header.configure(
            filter: filterRelay.value,
            sort: sortRelay.value,
            onFilter: { [weak self] newFilter in
                self?.filterRelay.accept(newFilter)     // ✅ Relay 갱신
            },
            onSort: { [weak self] newSort in
                self?.sortRelay.accept(newSort)         // ✅ Relay 갱신
            }
        )
        return header
    }
}
