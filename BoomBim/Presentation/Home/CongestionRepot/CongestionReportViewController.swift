//
//  CongestionReportViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/12/25.
//

import UIKit

final class CongestionReportViewController: UIViewController {
    private let viewModel: CongestionReportViewModel
    
    private let locationSearchView = LocationSearchFieldView()
    
    init(viewModel: CongestionReportViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
    }
    
    // MARK: Setup UI
    private func setupNavigationBar() {
        title = "혼잡도 공유"
    }
}
