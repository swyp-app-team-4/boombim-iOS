//
//  TermsBottomSheetViewController.swift
//  BoomBim
//
//  Created by 조영현 on 9/11/25.
//

import UIKit
import SafariServices

final class TermsBottomSheetViewController: UIViewController {
    // Public 콜백
    var onConfirm: ((_ items: [TermsModel]) -> Void)?
    
    // Data
    private var items: [TermsModel]
    
    // UI
    private let allAgreeView = CheckBoxRowView()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .grayScale3
        
        return view
    }()
    
    private let agreeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 10
        
        return stackView
    }()
    
    private var termsRows: [CheckRowView] = []
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .grayScale4
        button.setTitle( "nickname.button.signup".localized(), for: .normal)
        button.setTitleColor(.grayScale7, for: .normal)
        button.titleLabel?.font = Typography.Body02.medium.font
        button.layer.cornerRadius = 10
        
        return button
    }()
    
    // MARK: Init
    init(items: [TermsModel]) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        
        if let sheet = sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = 22
            
            sheet.detents = [.custom { _ in 320 }]
        }
        
        for item in items {
            let row = CheckRowView(info: item)
            termsRows.append(row)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        configureContent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let sheet = sheetPresentationController else { return }
        // Recalculate after layout so the custom detent matches current content size
        let width = sheet.largestUndimmedDetentIdentifier == nil ? view.bounds.width : view.bounds.width
        let h = intrinsicContentHeight(forWidth: width)
        
        let minHeight: CGFloat = 250
        let maxHeight: CGFloat = view.bounds.height
        let target = minHeight // min(max(h, minHeight), maxHeight)
        
        sheet.detents = [.custom { _ in target }]
    }
    
    private func setupViews() {
        view.backgroundColor = .grayScale1
        
        termsRows.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            agreeStackView.addArrangedSubview($0)
        }
        
        [allAgreeView, lineView, agreeStackView, signUpButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        [allAgreeView, lineView, agreeStackView, signUpButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            allAgreeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            allAgreeView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            allAgreeView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            allAgreeView.heightAnchor.constraint(equalToConstant: 37),
            
            lineView.topAnchor.constraint(equalTo: allAgreeView.bottomAnchor, constant: 14),
            lineView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            lineView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            lineView.heightAnchor.constraint(equalToConstant: 1),
            
            agreeStackView.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 14),
            agreeStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            agreeStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            agreeStackView.bottomAnchor.constraint(equalTo: signUpButton.topAnchor, constant: -36),
            agreeStackView.heightAnchor.constraint(equalToConstant: 74),
            
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            signUpButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            signUpButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configureContent() {
        allAgreeView.configure(title: "term.title.all_agree".localized())
        allAgreeView.onToggleCheck = { [weak self] _ in
            print("handleAllAgreeTap")
            self?.handleAllAgreeTap()
        }

        // 각 약관 row의 체크 변경을 감지하여 items와 allAgreeView를 동기화
        for (index, row) in termsRows.enumerated() {
            // 개별 Row가 토글될 때 모델과 전체동의 상태를 동기화
            row.onToggleCheck = { [weak self] isChecked in
                guard let self = self else { return }
                // 모델 상태 갱신
                if self.items.indices.contains(index) {
                    self.items[index].isChecked = isChecked
                }
                // 모든 항목 체크 여부 계산
                let isAllChecked = self.items.allSatisfy { $0.isChecked }
                // 전체동의 UI 동기화 (재귀 방지 위해 emit: false)
                self.allAgreeView.setChecked(isAllChecked, emit: false)
                // 가입 버튼 상태 갱신(필수 항목 체크 여부 반영)
                self.updateConfirmButtonState()
            }
        }

        // 초기 버튼 상태 동기화
        updateConfirmButtonState()
        
        signUpButton.addTarget(self, action: #selector(tapConfirm), for: .touchUpInside)
    }
    
    // MARK: State Handling
    private func toggleAll(_ checked: Bool) {
        // 데이터/뷰 동기 갱신 (콜백 방지)
        for i in items.indices {
            items[i].isChecked = checked
            termsRows[i].setChecked(checked)
        }
        // 전체동의 UI도 재귀 없이 맞추기
        allAgreeView.setChecked(checked, emit: false)
        print("checkd: \(checked)")
        updateConfirmButtonState()
    }
    
    private func updateConfirmButtonState() {
        // 필수 항목 체크 여부
        let requiredOK = items.filter { $0.kind == .required }.allSatisfy { $0.isChecked }
        signUpButton.isEnabled = requiredOK
        // TODO: enable에 따른 색상
        if requiredOK {
            signUpButton.backgroundColor = .main
            signUpButton.setTitleColor(.grayScale1, for: .normal)
        } else {
            signUpButton.backgroundColor = .grayScale4
            signUpButton.setTitleColor(.grayScale7, for: .normal)
        }
    }
    
    @objc private func tapConfirm() {
        onConfirm?(items)
        dismiss(animated: true)
    }
    
    @objc private func handleAllAgreeTap() {
        // Determine current state from items and flip
        let allChecked = items.allSatisfy { $0.isChecked }
        let next = !allChecked
        toggleAll(next)
    }
    
    // MARK: Dynamic Height (for custom detent)
    private func intrinsicContentHeight(forWidth width: CGFloat) -> CGFloat {
        view.layoutIfNeeded()
        let target = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let height = view.systemLayoutSizeFitting(target, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
        return height
    }
}

// MARK: - Present Helper
extension UIViewController {
    func presentTermsSheet(items: [TermsModel], onConfirm: @escaping ([TermsModel]) -> Void) {
        let vc = TermsBottomSheetViewController(items: items)
        vc.onConfirm = onConfirm
        present(vc, animated: true)
    }
}

