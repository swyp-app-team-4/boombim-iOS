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
    private let grabberSpace = UIView()
    private let container = UIStackView()
    private let agreeAllRow = TermRowView(title: "전체 동의하기", checked: false, showChevron: false)
    private var itemRows: [String: TermRowView] = [:]
    private let confirmButton = UIButton(type: .system)
    
    // MARK: Init
    init(items: [TermsModel]) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.custom { [weak self] ctx in
                // 내용 높이 기반으로 동적 계산
                guard let self else { return 400 }
                let intrinsic = self.intrinsicContentHeight(forWidth: ctx.maximumDetentValue) // 실제 가용 폭 전달
                // 상한/하한 가드
                return min(max(intrinsic, 260), ctx.maximumDetentValue * 0.9)
            }]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = 16
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        buildRows()
        syncAgreeAllState()
        updateConfirmButtonState()
    }
    
    private func setupLayout() {
        // Safe-area 패딩
        let outer = UIStackView(arrangedSubviews: [])
        outer.axis = .vertical
        outer.spacing = 0
        view.addSubview(outer)
        outer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            outer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            outer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            outer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            outer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        
        // 상단 여백(그랩버 여지)
        grabberSpace.translatesAutoresizingMaskIntoConstraints = false
        grabberSpace.heightAnchor.constraint(equalToConstant: 6).isActive = true
        outer.addArrangedSubview(grabberSpace)
        
        // 내용 스택
        container.axis = .vertical
        container.spacing = 0
        outer.addArrangedSubview(container)
        
        // 하단 버튼 영역
        let buttonHolder = UIView()
        buttonHolder.layoutMargins = .init(top: 16, left: 20, bottom: 16, right: 20)
        outer.addArrangedSubview(buttonHolder)
        
        confirmButton.setTitle("회원가입", for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        confirmButton.layer.cornerRadius = 12
        confirmButton.clipsToBounds = true
        confirmButton.backgroundColor = .systemOrange
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.setTitleColor(.white.withAlphaComponent(0.5), for: .disabled)
        confirmButton.addTarget(self, action: #selector(tapConfirm), for: .touchUpInside)
        buttonHolder.addSubview(confirmButton)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            confirmButton.leadingAnchor.constraint(equalTo: buttonHolder.layoutMarginsGuide.leadingAnchor),
            confirmButton.trailingAnchor.constraint(equalTo: buttonHolder.layoutMarginsGuide.trailingAnchor),
            confirmButton.topAnchor.constraint(equalTo: buttonHolder.layoutMarginsGuide.topAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: buttonHolder.layoutMarginsGuide.bottomAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    private func buildRows() {
        // 전체 동의
        agreeAllRow.onToggleCheck = { [weak self] checked in
            self?.toggleAll(checked)
        }
        agreeAllRow.onOpenURL = nil // 전체동의는 URL 없음
        container.addArrangedSubview(agreeAllRow)
        
        // 섹션 구분선
        container.addArrangedSubview(divider())
        
        // 각 항목
        for item in items {
            let titlePrefix = item.kind == .required ? "(필수) " : "(선택) "
            let row = TermRowView(title: titlePrefix + item.title, checked: item.isChecked, showChevron: true)
            
            row.onToggleCheck = { [weak self] _ in
                guard let self else { return }
                // 상태 반영
                if let idx = self.items.firstIndex(where: { $0.id == item.id }) {
                    self.items[idx].isChecked = row.isChecked
                }
                self.syncAgreeAllState()
                self.updateConfirmButtonState()
            }
            row.onOpenURL = { [weak self] in
                guard let self else { return }
                let safari = SFSafariViewController(url: item.url)
                safari.modalPresentationStyle = .formSheet
                self.present(safari, animated: true)
            }
            itemRows[item.id] = row
            container.addArrangedSubview(row)
        }
    }
    
    private func divider() -> UIView {
        let v = UIView()
        v.backgroundColor = .secondarySystemBackground
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 8).isActive = true
        return v
    }
    
    // MARK: State Handling
    
    private func toggleAll(_ checked: Bool) {
        // UI + 데이터 모두 갱신
        for (i, it) in items.enumerated() {
            items[i].isChecked = checked || (it.kind == .optional ? checked : checked) // 모두 동일 토글
            itemRows[it.id]?.setChecked(checked)
        }
        updateConfirmButtonState()
    }
    
    private func syncAgreeAllState() {
        // 모든 항목이 체크되어 있으면 전체동의도 체크
        let allChecked = items.allSatisfy { $0.isChecked }
        agreeAllRow.setChecked(allChecked)
    }
    
    private func updateConfirmButtonState() {
        // 필수 항목 체크 여부
        let requiredOK = items.filter { $0.kind == .required }.allSatisfy { $0.isChecked }
        confirmButton.isEnabled = requiredOK
        confirmButton.alpha = requiredOK ? 1.0 : 0.5
    }
    
    @objc private func tapConfirm() {
        onConfirm?(items)
        dismiss(animated: true)
    }
    
    // MARK: Dynamic Height (for custom detent)
    private func intrinsicContentHeight(forWidth width: CGFloat) -> CGFloat {
        // 가상의 너비를 주고 오토레이아웃 수치 얻기
        view.layoutIfNeeded()
        let target = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let height = view.systemLayoutSizeFitting(target,
                                                 withHorizontalFittingPriority: .required,
                                                 verticalFittingPriority: .fittingSizeLevel).height
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

// MARK: - Example Usage
// 호출 측(예: 회원가입 화면)에서:
/*
let terms: [TermItem] = [
    .init(id: "tos", title: "이용약관 동의", url: URL(string:"https://example.com/tos")!, kind: .required, isChecked: false),
    .init(id: "privacy", title: "개인정보 처리방침 동의", url: URL(string:"https://example.com/privacy")!, kind: .required, isChecked: false),
    .init(id: "loc", title: "위치 정보 수집 동의", url: URL(string:"https://example.com/location")!, kind: .optional, isChecked: false),
    .init(id: "mkt", title: "마케팅 활용 및 광고성 정보 수신 동의", url: URL(string:"https://example.com/marketing")!, kind: .optional, isChecked: false),
]

presentTermsSheet(items: terms) { updated in
    // updated에 체크 최종 상태 들어있음
    // 필수 체크 확인 후 가입 로직 진행
}
*/
