//
//  VoteChatViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/22/25.
//

import UIKit
import RxSwift
import RxCocoa

final class VoteChatViewController: BaseViewController {
    private let viewModel: VoteChatViewModel
    private let disposeBag = DisposeBag()
    
    private let endVoteRelay = PublishRelay<(Int, Int)>()
    
    private var votes: [VoteChatItem] = []
    
    // 부모(상위 탭/페이지)에게 새로고침을 부탁할 콜백
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
    
    private let voteTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .tableViewBackground
        
        return tableView
    }()
    
    init(viewModel: VoteChatViewModel) {
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
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        if votes.isEmpty {
//            emptyStackView.isHidden = false
//            voteTableView.isHidden = true
//        } else {
//            emptyStackView.isHidden = true
//            voteTableView.isHidden = false
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
        voteTableView.delegate = nil
        voteTableView.dataSource = nil
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
    
    private func bind() {
        let output = viewModel.transform(.init(endVoteTap: endVoteRelay.asSignal()))
        
        // 목록 바인딩(예시)
        output.items
            .drive(voteTableView.rx.items(cellIdentifier: VoteChatCell.identifier, cellType: VoteChatCell.self)) { [weak self] _, item, cell in
                
                let voteChatItem: VoteChatItem = .init(
                    profileImage: item.profile,
                    people: item.profile.count,
                    update: DateHelper.displayString(from: item.createdAt),
                    title: item.posName,
                    roadImage: item.posImage,
                    congestion: self?.congestion(from: item) ?? .relaxed,
                    isVoting: !item.voteFlag)
                
                cell.configure(voteChatItem)
                cell.onVote = { selectedIndex in
                    guard let selectedIndex = selectedIndex else { return }
                    print("selectedIndex : \(selectedIndex)")
                    self?.endVoteRelay.accept((item.voteId, selectedIndex))
//                    self?.confirmEnd(voteId: item.voteId, congestionLevel: selectedIndex)
                    
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
                self.voteTableView.isHidden = true
                self.emptyStackView.isHidden = true
            } else {
                self.voteTableView.isHidden = isEmpty
                self.emptyStackView.isHidden = !isEmpty
            }
        })
        .disposed(by: disposeBag)
        
        output.error
            .emit(onNext: { [weak self] msg in
                self?.presentAlert(title: "붐빔", message: "본인이 생성한 투표에는 참여할 수 없습니다.")
            })
            .disposed(by: disposeBag)
        
        // 종료 성공 → 부모에게 목록 갱신 요청
        output.ended
            .emit(onNext: { [weak self] _ in self?.onNeedRefresh?() })
            .disposed(by: disposeBag)
    }
    
    // TODO: 투표하기
    private func confirmEnd(voteId: Int, congestionLevel: Int) {
        let ac = UIAlertController(title: "투표 종료", message: "이 투표를 종료할까요?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "취소", style: .cancel))
        ac.addAction(UIAlertAction(title: "종료", style: .destructive, handler: { [weak self] _ in
            self?.endVoteRelay.accept((voteId, congestionLevel))
        }))
        present(ac, animated: true)
    }
    
    func congestion(from r: VoteItemResponse) -> CongestionLevel? {
        if r.relaxedCnt == 1 { return .relaxed }
        if r.commonly == 1 { return .normal }
        if r.slightlyBusyCnt == 1 { return .busy }
        if r.crowedCnt == 1 { return .crowded }
        return nil
    }
}

//extension VoteChatViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        votes.count
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 16
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let index = indexPath.row
//        let vote = votes[index]
//        let cell = tableView.dequeueReusableCell(withIdentifier: VoteChatCell.identifier, for: indexPath) as! VoteChatCell
//        
////        cell.configure(vote)
////        cell.onVote = { [weak self, weak tableView] selectedIndex in
////            guard let self, let tableView, let currentIndexPath = tableView.indexPath(for: cell) // 재사용 대비, 최신 indexPath 구하기
////            else { return }
////            
////            print("vote Button Tapped : \(currentIndexPath.row)")
////            print("selectedIndex : \(selectedIndex)")
////        }
//        
//        return cell
//    }
//}
