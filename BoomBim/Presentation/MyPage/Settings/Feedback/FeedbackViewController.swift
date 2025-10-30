//
//  FeedbackViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/28/25.
//

import UIKit
import RxSwift
import RxCocoa

final class FeedbackViewController: BaseViewController {
    private let viewModel: FeedbackViewModel
    private let disposeBag = DisposeBag()
    
    private var selectedReasons = Set<WithdrawReason>()
    private var otherText: String = ""
    
    // 데이터 소스용
    private let reasons: [WithdrawReason] = [.notOftenUse, .inconvenient, .badService, .newAccount, .privacyConcern, .other]
    
    private let selectedReasonsRelay = BehaviorRelay<Set<WithdrawReason>>(value: [])
    private let otherTextRelay = BehaviorRelay<String>(value: "")
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        let text = "정말 탈퇴하시겠어요?"
        label.setText(text, style: Typography.Heading02.semiBold)
        label.textColor = .grayScale10
        label.textAlignment = .left
        
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        let text = "지금까지 작성한 모든 정보가 사라집니다.\n소중한 의견을 받아 더 나은 서비스를 만들어갈게요."
        label.setText(text, style: Typography.Body03.regular)
        label.textColor = .grayScale8
        label.textAlignment = .left
        label.numberOfLines = 2
        
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.sectionHeaderTopPadding = 0
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .tableViewDivider
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        return tableView
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 6
        
        return stackView
    }()
    
    private let keepButton: UIButton = {
        let button = UIButton()
        button.setTitle("계속 이용하기", for: .normal)
        button.titleLabel?.font = Typography.Body02.medium.font
        button.setTitleColor(.grayScale1, for: .normal)
        button.backgroundColor = .main
        button.layer.cornerRadius = 10
        button.isEnabled = false
        
        return button
    }()
    
    private let withdrawButton: UIButton = {
        let button = UIButton()
        button.setTitle("탈퇴하기", for: .normal)
        button.titleLabel?.font = Typography.Body02.medium.font
        button.setTitleColor(.main, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.main.cgColor
        button.isEnabled = false
        
        return button
    }()
    
    init(viewModel: FeedbackViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "탈퇴하기"
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bind()
        
        updateWithdrawButtonState()
    }
    
    private func setupView() {
        view.backgroundColor = .background
        
        setupKeyboardHandling()
        
        setupNavigationBar()
        setupTitle()
        configureButton()
        setupTableView()
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShowHide(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShowHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupNavigationBar() {
        navigationController?.view.backgroundColor = .background
    }
    
    private func setupTitle() {
        [titleLabel, subTitleLabel].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            subTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: .zero) // 빈행 구분선 제거
        
        tableView.keyboardDismissMode = .interactive
        tableView.register(ReasonCell.self, forCellReuseIdentifier: "ReasonCell")
        
        tableView.backgroundColor = .background
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 14),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -12)
        ])
    }
    
    private func configureButton() {
        [keepButton, withdrawButton].forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            buttonStackView.addArrangedSubview(button)
        }
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            keepButton.heightAnchor.constraint(equalToConstant: 44),
            withdrawButton.heightAnchor.constraint(equalToConstant: 44),
            buttonStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func bind() {
        // ViewModel 바인딩
        let input = FeedbackViewModel.Input(
            withdrawTap: withdrawButton.rx.tap.asSignal(),
            selectedReasons: selectedReasonsRelay.asDriver(),
            otherText: otherTextRelay.asDriver()
        )
        let output = viewModel.transform(input)
        
        // 버튼 활성화
        output.isWithdrawEnabled
            .drive(withdrawButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 로딩 처리(예: 버튼 비활성/alpha 변경 등)
        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                self?.view.isUserInteractionEnabled = !isLoading
                self?.withdrawButton.alpha = isLoading ? 0.5 : 1.0
            })
            .disposed(by: disposeBag)
        
        // 성공 토스트/알럿
        output.withdrawSuccess
            .emit(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.presentWithdrawDone()
            })
            .disposed(by: disposeBag)
        
        // 오류 토스트
        output.error
            .emit(onNext: { [weak self] msg in
                print("에러")
            })
            .disposed(by: disposeBag)
        
        keepButton.rx.tap
            .asSignal()
            .emit(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func updateWithdrawButtonState() {
        let hasReason = !selectedReasons.isEmpty
        let needsOther = selectedReasons.contains(.other)
        let otherOK = !needsOther || !otherText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let enabled = hasReason && otherOK
        
        print("enabled: \(enabled)")
        
        withdrawButton.isEnabled = enabled
        withdrawButton.alpha = enabled ? 1.0 : 0.5
    }
    
    @objc private func kbWillShowHide(_ note: Notification) {
        guard
            let userInfo = note.userInfo,
            let end = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }
        
        let converted = view.convert(end, from: nil)
        let overlap = max(0, view.bounds.maxY - converted.minY) // 키보드가 가리는 높이
        let insetBottom = overlap + buttonStackView.bounds.height // bottomBar까지 고려
        
        UIView.animate(withDuration: duration, delay: 0, options: .init(rawValue: curveRaw)) {
            self.tableView.contentInset.bottom = insetBottom
            self.tableView.scrollIndicatorInsets.bottom = insetBottom
        }
    }
    
    private func presentWithdrawDone() {
        AppDialogController.showOK(
            on: self,
            title: "탈퇴가 완료되었습니다",
            onOK: {
                TokenManager.shared.clear(type: .withdraw)
            })
    }
}

extension FeedbackViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reasons.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReasonCell", for: indexPath) as! ReasonCell
            let reason = reasons[indexPath.row]

            let showText = (reason == .other) && selectedReasons.contains(.other)
            cell.configure(
                title: reason.title,
                checked: selectedReasons.contains(reason),
                showTextView: showText,
                initialText: otherText,
                onChange: { [weak self] text in
                    self?.otherText = text
                    self?.updateWithdrawButtonState()
                }
            )
            return cell
    }
    
    // 선택 처리
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reason = reasons[indexPath.row]

        if selectedReasons.contains(reason) {
            selectedReasons.remove(reason)
            if reason == .other { otherText = "" }
        } else {
            selectedReasons.insert(reason)
        }
        updateWithdrawButtonState()

        // ‘기타’ 행만 다시 그리면 됨
        if reason == .other, let otherRow = reasons.firstIndex(of: .other) {
            let ip = IndexPath(row: otherRow, section: 0)
            tableView.reloadRows(at: [ip], with: .automatic)

            // 보이게 된 직후 포커스 & 가시영역 보장
            if selectedReasons.contains(.other) {
                DispatchQueue.main.async {
                    tableView.scrollToRow(at: ip, at: .middle, animated: true)
                    (tableView.cellForRow(at: ip) as? ReasonCell)?.beginEditing()
                }
            }
        } else {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isLastRow  = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        if isLastRow {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = tableView.separatorInset
        }
    }
}

