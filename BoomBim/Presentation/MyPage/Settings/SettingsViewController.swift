//
//  SettingsViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/11/25.
//

import UIKit
import RxSwift
import SafariServices

final class SettingsViewController: BaseViewController {
    private let viewModel: SettingsViewModel
    private let disposeBag = DisposeBag()

    private let rows = SettingsRow.allCases
    
    // MARK: - UI
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .white
        
        return tableView
    }()
    
    private let tableFooterView = SettingsFooterView()
    
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "설정"
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
        view.backgroundColor = .white
        
        setupNavigationBar()
        configureTableView()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .grayScale9
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none

        tableView.register(SettingCell.self, forCellReuseIdentifier: SettingCell.identifier)
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: CGFloat.leastNonzeroMagnitude))
        
        tableView.tableFooterView = tableFooterView
        resizeTableFooterToFit()
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // 2) footer의 실제 height를 계산해서 tableFooterView에 반영
    private func resizeTableFooterToFit() {
        guard let footer = tableView.tableFooterView else { return }

        // footer의 레이아웃을 먼저 계산
        footer.setNeedsLayout()
        footer.layoutIfNeeded()

        // 테이블 너비 기준으로 fitting
        let targetWidth = tableView.bounds.width
        let size = footer.systemLayoutSizeFitting(
            CGSize(width: targetWidth, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        // 높이/너비가 바뀌면 frame 갱신 후 "다시 대입"해야 적용됩니다.
        if footer.frame.width != targetWidth || footer.frame.height != size.height {
            footer.frame.size = CGSize(width: targetWidth, height: size.height)
            tableView.tableFooterView = footer
        }
    }
    
    private func bind() {
        // 1) Input
        let input = SettingsViewModel.Input(
            logoutTap: tableFooterView.logoutButton.rx.tap.asSignal(),
            withdrawTap: tableFooterView.withdrawButton.rx.tap.asSignal()
        )
        
        // 2) Transform
        let output = viewModel.transform(input)
        
        // 3) 로딩 인디케이터
        output.isLoading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        // 4) 로딩 중 버튼 비활성화 (중복 탭 방지)
        output.isLoading
            .map { !$0 }
            .drive(tableFooterView.logoutButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 5) 에러 토스트/알럿
        output.error
            .emit(onNext: { [weak self] msg in
                self?.presentAlert(title: "오류", message: msg)
            })
            .disposed(by: disposeBag)
        
        // ✅ 피드백에서 사유가 도착하면 알럿 표시
        viewModel.reasonSelected
            .emit(onNext: { [weak self] reason in
                self?.presentWithdrawConfirm(reason: reason)
            })
            .disposed(by: disposeBag)
    }
    
    private func presentWithdrawConfirm(reason: String) {
        let msg = "작성하신 탈퇴 사유:\n\"\(reason)\"\n정말 탈퇴하시겠어요?"
        let ac = UIAlertController(title: "회원 탈퇴", message: msg, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "취소", style: .cancel))
        ac.addAction(UIAlertAction(title: "확인", style: .destructive) { [weak self] _ in
            self?.viewModel.confirmWithdraw(reason: reason) // ← VM에 실행 요청
        })
        present(ac, animated: true)
    }
    
    func openSafariView(url: String) {
        guard let url = URL(string: url) else { return }
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        
        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredBarTintColor = .white
        vc.preferredControlTintColor = .systemBlue
        if #available(iOS 11.0, *) { vc.dismissButtonStyle = .close }
        
        present(vc, animated: true)
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.identifier, for: indexPath) as! SettingCell
        
        let index = indexPath.row
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.configure(title: rows[index].title)
        
        return cell
    }

    // MARK: - Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = rows[indexPath.row]
        
        switch row {
        case .profile:
            return
        case .push:
            return
        case .terms:
            openSafariView(url: "https://awesome-captain-026.notion.site/2529598992b080119479fef036d96aba?source=copy_link")
        case .privacy:
            openSafariView(url: "https://awesome-captain-026.notion.site/2529598992b080198821d47baaf7d23f?source=copy_link")
        case .guide:
            openSafariView(url: "https://awesome-captain-026.notion.site/25b9598992b08065a7ccf361e3f8ccf8?source=copy_link")
        case .support:
            openSafariView(url: "https://awesome-captain-026.notion.site/25b9598992b0804fb058d1310b6ecdf0?source=copy_link")
        case .faq:
            return
        }
    }
}
